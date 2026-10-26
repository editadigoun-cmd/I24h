import 'package:flutter/material.dart';
import '../../core/services/i24h_live_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AnimateurLiveScreen extends StatefulWidget {
  const AnimateurLiveScreen({super.key});

  @override
  State<AnimateurLiveScreen> createState() => _AnimateurLiveScreenState();
}

class _AnimateurLiveScreenState extends State<AnimateurLiveScreen> {
  final I24HLiveService _liveService = I24HLiveService();
  bool _live = false;
  bool _mic = false;
  bool _busy = false;
  String? _error;

  Future<void> _toggleLive() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      if (_live) {
        await _liveService.disconnect();
        if (mounted) setState(() { _live = false; _mic = false; });
      } else {
        await _liveService.connect(
          participantName: 'Animateur I24H',
          publishAudio: true,
        );
        if (mounted) setState(() { _live = true; _mic = true; });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleMic() async {
    if (!_live || _busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      await _liveService.setMicrophoneEnabled(!_mic);
      if (mounted) setState(() => _mic = !_mic);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _liveService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
    children: [
      const Text('CONSOLE DE DIFFUSION', style: TextStyle(color: AppColors.blue, fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w900)),
      const SizedBox(height: 7),
      const Text('Studio I24H', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -.7)),
      const SizedBox(height: 6),
      const Text('Studio connecté au serveur LiveKit via le Worker sécurisé.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4)),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.navy, Color(0xFF163B69)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 43, height: 43, decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 24)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LE GRAND DIRECT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: .5, fontSize: 13)),
              SizedBox(height: 4),
              Text('Salle LiveKit · i24h-live', style: TextStyle(color: Colors.white60, fontSize: 11)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: _live ? AppColors.live : Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(8)), child: Text(_live ? 'CONNECTÉ' : 'VEILLE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: .8))),
          ]),
          const SizedBox(height: 28),
          Center(child: Container(
            width: 92, height: 92,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.08), border: Border.all(color: _live ? AppColors.live : Colors.white24, width: 2)),
            child: Icon(_live ? Icons.graphic_eq_rounded : Icons.mic_none_rounded, color: Colors.white, size: 39),
          )),
          const SizedBox(height: 15),
          Center(child: Text(_live ? 'STUDIO CONNECTÉ' : 'PRÊT À SE CONNECTER', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.1, fontSize: 12))),
          const SizedBox(height: 5),
          Center(child: Text(_live ? 'Le studio a rejoint la salle LiveKit' : 'La connexion vérifie le jeton serveur', style: const TextStyle(color: Colors.white60, fontSize: 11))),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: FilledButton.icon(
              onPressed: _busy ? null : _toggleLive,
              icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(_live ? Icons.stop_rounded : Icons.play_arrow_rounded),
              label: Text(_busy ? 'Connexion…' : _live ? 'Quitter le studio' : 'Connecter le studio'),
              style: FilledButton.styleFrom(backgroundColor: _live ? AppColors.live : Colors.white, foregroundColor: _live ? Colors.white : AppColors.navy),
            )),
            const SizedBox(width: 10),
            SizedBox(height: 52, width: 54, child: IconButton.filledTonal(
              onPressed: _live && !_busy ? _toggleMic : null,
              style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(.13), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              icon: Icon(_mic ? Icons.mic_rounded : Icons.mic_off_rounded),
              tooltip: _mic ? 'Couper le micro' : 'Activer le micro',
            )),
          ]),
        ]),
      ),
      if (_error != null) ...[
        const SizedBox(height: 14),
        I24HCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.live),
          const SizedBox(width: 10),
          Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.live, fontSize: 12))),
        ])),
      ],
      const SizedBox(height: 23),
      const Text('ÉTAT DU STUDIO', style: TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
      const SizedBox(height: 11),
      I24HCard(child: Column(children: [
        _statusRow('Connexion LiveKit', _live ? 'Connecté' : 'Déconnecté', _live),
        const Divider(height: 18, color: AppColors.line),
        _statusRow('Microphone', _live ? (_mic ? 'Activé' : 'Muet') : 'En attente', _live && _mic),
        const Divider(height: 18, color: AppColors.line),
        _statusRow('Jeton de session', _error == null ? 'Demandé au Worker' : 'Erreur', _error == null),
      ])),
      const SizedBox(height: 22),
      const Text('À SAVOIR', style: TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      const I24HCard(child: Text('Le compte animateur doit disposer d’un créneau publié et actif dans Supabase. Si le Worker ou les secrets LiveKit ne sont pas configurés, le message d’erreur apparaîtra ici.', style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.muted))),
    ],
  );

  Widget _statusRow(String title, String value, bool ok) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Icon(ok ? Icons.check_circle_rounded : Icons.info_outline_rounded, color: ok ? AppColors.success : AppColors.muted, size: 19),
      const SizedBox(width: 10),
      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
      Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(color: AppColors.muted, fontSize: 11))),
    ]),
  );
}
