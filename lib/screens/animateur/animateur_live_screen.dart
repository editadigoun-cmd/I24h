import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AnimateurLiveScreen extends StatefulWidget {
  const AnimateurLiveScreen({super.key});

  @override
  State<AnimateurLiveScreen> createState() => _AnimateurLiveScreenState();
}

class _AnimateurLiveScreenState extends State<AnimateurLiveScreen> {
  bool live = false;
  bool mic = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Studio de diffusion',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Un espace simple pour piloter votre direct.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 18),
        Container(
          height: 210,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    live ? Icons.graphic_eq : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  live ? 'VOUS ÊTES EN DIRECT' : 'PRÊT À DIFFUSER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  live ? 'Le Grand Direct · 14:00 — 18:00' : 'Aucun direct en cours',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => setState(() => live = !live),
                icon: Icon(live ? Icons.stop_rounded : Icons.play_arrow_rounded),
                label: Text(live ? 'Arrêter le direct' : 'Démarrer le direct'),
                style: FilledButton.styleFrom(
                  backgroundColor: live ? AppColors.danger : AppColors.navy,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              onPressed: () => setState(() => mic = !mic),
              icon: Icon(mic ? Icons.mic_rounded : Icons.mic_off_rounded),
              tooltip: 'Microphone',
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionTitle(title: 'Contrôles'),
        I24HCard(
          child: Column(
            children: [
              _statusRow('Microphone', mic ? 'Actif' : 'Muet', mic),
              _statusRow('Caméra', 'Prête', true),
              _statusRow('Connexion', '18 Mbps · Stable', true),
              _statusRow('Console', 'Opérationnelle', true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Note : les commandes de direct sont actuellement une démonstration locale.',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _statusRow(String title, String value, bool ok) {
    final color = ok ? AppColors.success : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.pause_circle_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
