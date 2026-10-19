import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/i24h_config.dart';

/// Data access for the authenticated faithful mobile application.
/// Admin publishing and payment confirmation must happen server-side.
class I24HBackend {
  I24HBackend._();

  static bool get isReady => I24HConfig.backendReady;

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> publishedPrograms() async {
    if (!isReady) return [];
    final rows = await _client
        .from('programs')
        .select('id,title,description,presenter,starts_at,ends_at')
        .eq('is_published', true)
        .order('starts_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<List<Map<String, dynamic>>> publishedReplays() async {
    if (!isReady) return [];
    final rows = await _client
        .from('replay_items')
        .select('id,title,description,presenter,media_path,duration_seconds,recorded_at')
        .eq('is_published', true)
        .order('recorded_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<String> replaySignedUrl(String mediaPath) async {
    if (!isReady) {
      throw StateError('Le backend I24H n’est pas configuré.');
    }
    return _client.storage
        .from('i24h-replays')
        .createSignedUrl(mediaPath, 60 * 60);
  }

  static Future<List<Map<String, dynamic>>> myPrayerIntentions() async {
    if (!isReady) return [];
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Connectez-vous pour consulter vos intentions.');
    final rows = await _client
        .from('prayer_intentions')
        .select('id,message,status,created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> submitPrayerIntention(String message) async {
    if (!isReady) {
      throw StateError('Le backend I24H n’est pas configuré.');
    }
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Connectez-vous pour envoyer une intention.');
    final trimmed = message.trim();
    if (trimmed.length < 3 || trimmed.length > 3000) {
      throw ArgumentError('Votre intention doit contenir entre 3 et 3000 caractères.');
    }
    await _client.from('prayer_intentions').insert({
      'user_id': user.id,
      'message': trimmed,
      'is_private': true,
    });
  }

  static Future<void> signOut() async {
    if (!isReady) return;
    await _client.auth.signOut();
  }
}
