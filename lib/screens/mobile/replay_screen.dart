import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ReplayScreen extends StatelessWidget {
  const ReplayScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('I24H Focus', 'Hier · 58 min', Icons.mic_none_rounded),
      ('Paroles & enseignements', 'Lundi · 42 min', Icons.auto_stories_outlined),
      ('Le Grand Direct', 'Dimanche · 1 h 14', Icons.graphic_eq_rounded),
      ('La communauté I24H', 'Samedi · 36 min', Icons.groups_outlined),
    ];
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
      const Text('Replay', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Réécoutez vos émissions préférées.', style: TextStyle(color: AppColors.muted)),
      const SizedBox(height: 20),
      ...items.map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)), child: Icon(r.$3, color: AppColors.blue)), title: Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(r.$2), trailing: IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lecture de ${r.$1}'))), icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.navy, size: 30))))),
    ]));
  }
}
