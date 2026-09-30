import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Soutenir I24H', style: TextStyle(fontWeight: FontWeight.w800))), body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 28), children: [
    I24HCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.favorite_rounded, color: AppColors.gold, size: 30), const SizedBox(height: 14), const Text('Votre soutien fait vivre la mission', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.ink)), const SizedBox(height: 8), const Text('Contribuez au développement de la radio et de ses programmes.', style: TextStyle(color: AppColors.muted, height: 1.5)), const SizedBox(height: 18), PrimaryButton(label: 'Faire un don', onPressed: () => _open(context), icon: Icons.favorite_border)])),
    const SizedBox(height: 20), const SectionTitle(title: 'Pourquoi donner ?'),
    ...['Produire de nouveaux programmes', 'Maintenir la diffusion 24/7', 'Développer la communauté'].map((x) => Padding(padding: const EdgeInsets.only(bottom: 9), child: I24HCard(child: Row(children: [const Icon(Icons.check_circle_outline_rounded, color: AppColors.success), const SizedBox(width: 11), Expanded(child: Text(x, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)))])))),
  ]));

  static void _open(BuildContext context) => showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 30), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Choisir un montant', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 16), Wrap(spacing: 9, runSpacing: 9, children: [5000, 10000, 25000, 50000].map((amount) => OutlinedButton(onPressed: () {Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Don de $amount FCFA sélectionné')));}, child: Text('$amount FCFA'))).toList())]));
}
