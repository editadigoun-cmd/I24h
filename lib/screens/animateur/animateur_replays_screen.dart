import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AnimateurReplaysScreen extends StatelessWidget {
  const AnimateurReplaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const replays = [
      'Le Grand Direct · Aujourd’hui',
      'I24H Focus · Hier',
      'Réveil du Matin · Lundi',
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Mes replays',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Retrouvez vos dernières émissions publiées.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 18),
        ...replays.map(
          (replay) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: I24HCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppColors.navy,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      replay,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lecture de $replay à connecter')),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    tooltip: 'Lire le replay',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
