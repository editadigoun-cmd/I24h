import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AnimateurProfileScreen extends StatelessWidget {
  const AnimateurProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        I24HCard(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.navy,
                child: Text(
                  'EA',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edith A.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Animatrice · Studio A',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modification du profil à connecter')),
                ),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Modifier le profil',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        I24HCard(
          child: Column(
            children: [
              _profileItem(context, 'Préférences studio', Icons.tune_rounded),
              _profileItem(context, 'Notifications', Icons.notifications_none_rounded),
              _profileItem(context, 'Sécurité', Icons.lock_outline_rounded),
              _profileItem(context, 'Aide', Icons.help_outline_rounded),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            'Se déconnecter',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    );
  }

  Widget _profileItem(BuildContext context, String label, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.navy),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label : écran à connecter')),
      ),
    );
  }
}
