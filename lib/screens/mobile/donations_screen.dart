import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reasons = [
      'Produire de nouveaux programmes',
      'Maintenir la diffusion 24/7',
      'Développer la communauté',
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const Text(
            'Soutenir I24H',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Votre soutien aide la radio à rester disponible 24/7.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.favorite_rounded, color: AppColors.gold, size: 32),
                  const SizedBox(height: 14),
                  const Text(
                    'Votre soutien fait vivre la mission',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Contribuez au développement de la radio et de ses programmes.',
                    style: TextStyle(color: AppColors.muted, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => _open(context),
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Faire un don'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pourquoi donner ?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.blue,
                  ),
                  title: Text(
                    reason,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir un montant',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [5000, 10000, 25000, 50000]
                  .map(
                    (amount) => OutlinedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Don de $amount FCFA sélectionné')),
                        );
                      },
                      child: Text('$amount FCFA'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
