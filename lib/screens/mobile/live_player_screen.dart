import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../core/config/i24h_config.dart';
import '../../core/services/i24h_live_service.dart';
import '../../core/theme/app_theme.dart';

class LivePlayerScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isLive;
  final String? audioUrl;

  const LivePlayerScreen({
    super.key,
    this.title = 'Le direct vidéo I24H',
    this.subtitle = 'La foi en mouvement, ensemble.',
    this.isLive = true,
    this.audioUrl,
  });

  @override
  State<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends State<LivePlayerScreen> {
  late final AudioPlayer _audioPlayer;
  VideoPlayerController? _videoController;
  bool _audioOnly = false;
  bool _loading = false;
  bool _playing = false;
  String? _errorMessage;
  final I24HLiveService _liveService = I24HLiveService();
  EventsListener<RoomEvent>? _roomListener;
  VideoTrack? _remoteVideoTrack;

  String get _videoUrl => widget.isLive ? I24HConfig.liveVideoUrl.trim() : '';

  String get _audioUrl {
    final replayUrl = widget.audioUrl?.trim() ?? '';
    if (replayUrl.isNotEmpty) return replayUrl;
    final audioOnlyUrl = I24HConfig.liveAudioUrl.trim();
    if (audioOnlyUrl.isNotEmpty) return audioOnlyUrl;
    return I24HConfig.liveStreamUrl.trim();
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    if (widget.isLive && _videoUrl.isNotEmpty) {
      unawaited(_initializeVideo());
    }
  }

  Future<void> _initializeVideo() async {
    if (_videoUrl.isEmpty || _videoController?.value.isInitialized == true) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    VideoPlayerController? controller;
    try {
      final createdController =
          VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
      controller = createdController;
      await createdController.initialize();
      await createdController.setLooping(true);
      if (!mounted) {
        await createdController.dispose();
        return;
      }
      final previous = _videoController;
      setState(() {
        _videoController = createdController;
        _playing = true;
      });
      if (previous != null) await previous.dispose();
      await createdController.play();
    } catch (error) {
      await controller?.dispose();
      if (mounted) {
        setState(() {
          _errorMessage = 'Impossible de charger le flux vidéo. Vérifiez l’URL HLS/HTTPS et le service de diffusion.';
          _playing = false;
        });
      }
      debugPrint('I24H live video error: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    unawaited(_roomListener?.dispose());
    unawaited(_liveService.disconnect());
    unawaited(_audioPlayer.dispose());
    final controller = _videoController;
    if (controller != null) unawaited(controller.dispose());
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_loading) return;
    setState(() => _errorMessage = null);

    if (widget.isLive) {
      setState(() => _loading = true);
      try {
        if (_liveService.isConnected) {
          await _roomListener?.dispose();
          _roomListener = null;
          await _liveService.disconnect();
          if (mounted) setState(() { _playing = false; _remoteVideoTrack = null; });
        } else {
          final room = await _liveService.connect(participantName: 'Auditeur I24H', publishAudio: false);
          final listener = room.createListener();
          listener.on<TrackSubscribedEvent>((event) {
            if (event.track is VideoTrack && mounted) {
              setState(() => _remoteVideoTrack = event.track as VideoTrack);
            }
          });
          listener.on<TrackUnsubscribedEvent>((event) {
            if (event.track is VideoTrack && mounted) setState(() => _remoteVideoTrack = null);
          });
          _roomListener = listener;
          if (mounted) setState(() => _playing = true);
        }
      } catch (error) {
        if (mounted) setState(() { _playing = false; _errorMessage = error.toString().replaceFirst('Bad state: ', ''); });
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    if (!widget.isLive || _audioOnly) {
      if (_audioUrl.isEmpty) {
        setState(() {
          _errorMessage = widget.isLive
              ? 'Le flux audio seul n’est pas configuré. Il faut fournir une URL audio dédiée pour économiser réellement les données.'
              : 'Le fichier audio de ce replay n’est pas disponible.';
        });
        return;
      }
      setState(() => _loading = true);
      try {
        if (_audioPlayer.audioSource == null) {
          await _audioPlayer.setUrl(_audioUrl);
        }
        if (_audioPlayer.playing) {
          await _audioPlayer.pause();
          if (mounted) setState(() => _playing = false);
        } else {
          unawaited(_audioPlayer.play());
          if (mounted) setState(() => _playing = true);
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Impossible de lire le flux audio. Vérifiez la connexion et la source de diffusion.';
            _playing = false;
          });
        }
        debugPrint('I24H live audio error: $error');
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      if (_videoUrl.isEmpty) {
        setState(() {
          _errorMessage = 'Le flux vidéo officiel I24H n’est pas encore configuré.';
        });
      } else {
        await _initializeVideo();
      }
      return;
    }

    try {
      if (controller.value.isPlaying) {
        await controller.pause();
        if (mounted) setState(() => _playing = false);
      } else {
        await controller.play();
        if (mounted) setState(() => _playing = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'La lecture vidéo a été interrompue. Réessayez.');
      }
    }
  }

  Future<void> _setAudioOnly(bool enabled) async {
    if (!widget.isLive || _audioOnly == enabled) return;
    if (enabled && _audioUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Le mode écoute seule nécessite un flux audio dédié fourni par le service de streaming.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      if (enabled) {
        await _videoController?.pause();
        await _audioPlayer.setUrl(_audioUrl);
        if (!mounted) return;
        setState(() {
          _audioOnly = true;
          _playing = true;
        });
        unawaited(_audioPlayer.play());
      } else {
        await _audioPlayer.pause();
        if (!mounted) return;
        setState(() {
          _audioOnly = false;
          _playing = false;
        });
        if (_videoController == null && _videoUrl.isNotEmpty) {
          await _initializeVideo();
        } else if (_videoController?.value.isInitialized == true) {
          await _videoController!.play();
          if (mounted) setState(() => _playing = true);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = enabled
              ? 'Impossible de démarrer le flux audio seul.'
              : 'Impossible de reprendre la vidéo.';
        });
      }
      debugPrint('I24H playback mode error: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideoAvailable = widget.isLive &&
        !_audioOnly &&
        _videoController?.value.isInitialized == true;

    return Scaffold(
      backgroundColor: const Color(0xFF07152E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07152E), Color(0xFF0C2343), Color(0xFF102E56)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 18, 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                      ),
                      const Expanded(
                        child: Text(
                          'I24H • LIVE EXPERIENCE',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFFB7C9E4), fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Partager',
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Le partage du direct sera relié dans la prochaine étape.')),
                        ),
                        icon: const Icon(Icons.ios_share_rounded, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_remoteVideoTrack != null && widget.isLive && !_audioOnly)
                            VideoTrackRenderer(_remoteVideoTrack!, fit: VideoViewFit.cover)
                          else if (isVideoAvailable)
                            VideoPlayer(_videoController!)
                          else
                            _VideoPlaceholder(
                              audioOnly: _audioOnly,
                              isLive: widget.isLive,
                              loading: _loading || (widget.isLive && _videoUrl.isNotEmpty && _videoController == null),
                            ),
                          Positioned(
                            left: 14,
                            top: 14,
                            child: _StatusPill(
                              label: widget.isLive ? (_audioOnly ? 'ÉCOUTE SEULE' : 'DIRECT') : 'REPLAY',
                              color: _audioOnly ? AppColors.cyan : const Color(0xFFFF5D70),
                            ),
                          ),
                          if (isVideoAvailable)
                            Positioned(
                              right: 14,
                              top: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.wifi_tethering_rounded, color: AppColors.cyan, size: 14),
                                    SizedBox(width: 6),
                                    Text('STREAMING', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(color: Colors.white, fontSize: 25, height: 1.15, fontWeight: FontWeight.w900, letterSpacing: -.6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(color: Color(0xFFB8C9E2), fontSize: 13, height: 1.45),
                      ),
                      const SizedBox(height: 20),
                      if (widget.isLive)
                        Container(
                          padding: const EdgeInsets.fromLTRB(15, 13, 10, 13),
                          decoration: BoxDecoration(
                            color: const Color(0xFF102A4C),
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: const Color(0x334C8DFF)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C4777),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(Icons.headphones_rounded, color: AppColors.cyan, size: 21),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mode économie de données', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                                    SizedBox(height: 4),
                                    Text('Écoutez le direct sans charger la vidéo.', style: TextStyle(color: Color(0xFFA7BCD8), fontSize: 10, height: 1.35)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _audioOnly,
                                onChanged: _loading ? null : _setAudioOnly,
                                activeColor: AppColors.cyan,
                                activeTrackColor: const Color(0xFF276E94),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _loading ? null : _togglePlayback,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0x557E9BC3)),
                                minimumSize: const Size(0, 54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                              ),
                              icon: _loading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyan))
                                  : Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 23),
                              label: Text(_playing ? 'Mettre en pause' : 'Lancer la lecture', style: const TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: const Color(0x22FF667A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x55FF667A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Color(0xFFFFA3AF), size: 19),
                              const SizedBox(width: 9),
                              Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFFFD9DE), fontSize: 11, height: 1.45))),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: AppColors.gold, size: 17),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Une expérience conçue pour rester accessible, même avec une connexion limitée.',
                              style: TextStyle(color: Color(0xFF9DB3D2), fontSize: 10, height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final bool audioOnly;
  final bool isLive;
  final bool loading;

  const _VideoPlaceholder({
    required this.audioOnly,
    required this.isLive,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF153D6A), Color(0xFF08172F), Color(0xFF17345C)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -45,
            top: -65,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x225FE3FF), width: 24),
              ),
            ),
          ),
          Positioned(
            left: -55,
            bottom: -90,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x22E8B65A), width: 22),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2)
              else
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1B4779),
                    border: Border.all(color: const Color(0x668BE8FF)),
                    boxShadow: const [BoxShadow(color: Color(0x332E9BFF), blurRadius: 30, spreadRadius: 4)],
                  ),
                  child: Icon(
                    audioOnly ? Icons.headphones_rounded : Icons.live_tv_rounded,
                    color: AppColors.cyan,
                    size: 33,
                  ),
                ),
              const SizedBox(height: 13),
              Text(
                audioOnly ? 'ÉCOUTE SEULE' : (isLive ? 'I24H • DIRECT VIDÉO' : 'I24H • REPLAY'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.6),
              ),
              const SizedBox(height: 6),
              Text(
                loading ? 'Connexion au flux…' : (audioOnly ? 'La parole, sans la vidéo.' : 'Le flux officiel sera affiché ici.'),
                style: const TextStyle(color: Color(0xFFB8C9E2), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.48),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(.55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 8, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}
