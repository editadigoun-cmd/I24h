import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/i24h_icon.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Mon profil', style: TextStyle(fontWeight: FontWeight.w800))), body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 28), children: [
    I24HCard(child: Row(children: [const CircleAvatar(radius: 29, backgroundColor: AppColors.navy, child: Text('EA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Utilisateur I24H', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)), SizedBox(height: 4), Text('Compte personnel', style: TextStyle(color: AppColors.muted, fontSize: 12))])), IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil modifié'))), icon: const Icon(Icons.edit_outlined))])),
    const SizedBox(height: 20),
    ...[
      ('Notifications', Icons.notifications_none_rounded), ('Préférences', Icons.tune_rounded), ('Confidentialité', Icons.lock_outline_rounded), ('Aide & support', Icons.help_outline_rounded),
    ].map((item) => Padding(padding: const EdgeInsets.only(bottom: 9), child: I24HCard(child: InkWell(onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item.$1))), child: Row(children: [Icon(item.$2, color: AppColors.navy), const SizedBox(width: 13), Expanded(child: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink))), const Icon(Icons.chevron_right_rounded, color: AppColors.muted)]))))),
    const SizedBox(height: 10),
    OutlinedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Se déconnecter', style: TextStyle(color: AppColors.danger))),
    const SizedBox(height: 20), const Center(child: Text('I24H · Version native 1.0', style: TextStyle(color: AppColors.muted, fontSize: 11))),
  ]));
}
