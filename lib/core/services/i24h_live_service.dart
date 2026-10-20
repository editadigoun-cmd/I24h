import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Connects authenticated I24H users to LiveKit. API secrets remain server-side.
class I24HLiveService {
  I24HLiveService();

  static const String tokenEndpoint =
      'https://i24h.ccds22431.workers.dev/api/livekit/token';

  Room? _room;
  bool get isConnected => _room != null;
  Room? get room => _room;

  Future<Room> connect({
    required String participantName,
    required bool publishAudio,
    String? invitationCode,
  }) async {
    if (_room != null) return _room!;

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null || session.accessToken.isEmpty) {
      throw StateError('Connectez-vous à votre compte I24H avant de rejoindre le direct.');
    }

    final response = await http.post(
      Uri.parse(tokenEndpoint),
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'participant_name': participantName,
        if (invitationCode != null && invitationCode.trim().isNotEmpty)
          'invitation_code': invitationCode.trim(),
      }),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Impossible d’obtenir le jeton du direct.';
      try {
        final payload = jsonDecode(response.body);
        if (payload is Map && payload['error'] != null) {
          message = payload['error'].toString();
        }
      } catch (_) {}
      throw StateError(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final serverUrl = data['server_url'] as String?;
    final token = data['participant_token'] as String?;
    if (serverUrl == null || token == null || serverUrl.isEmpty || token.isEmpty) {
      throw StateError('La réponse du serveur de direct est incomplète.');
    }

    final room = Room();
    try {
      await room.connect(serverUrl, token);
      if (publishAudio || invitationCode != null) {
        await room.localParticipant?.setMicrophoneEnabled(true);
      } else {
        await room.startAudio();
      }
      _room = room;
      return room;
    } catch (_) {
      await room.disconnect();
      rethrow;
    }
  }

  Future<void> setCameraEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null) throw StateError('Le studio n’est pas connecté.');
    await participant.setCameraEnabled(enabled);
  }

  Future<void> setScreenShareEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null) throw StateError('Le studio n’est pas connecté.');
    await participant.setScreenShareEnabled(enabled);
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null) throw StateError('Le studio n’est pas connecté.');
    await participant.setMicrophoneEnabled(enabled);
  }

  Future<void> disconnect() async {
    final room = _room;
    _room = null;
    if (room != null) await room.disconnect();
  }
}
