import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class ReplayScreen extends StatelessWidget {
  const ReplayScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Replay', style: TextStyle(fontWeight: FontWeight.w800))), body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 28), children: [
    const Text('Réécoutez vos émissions préférées', style: TextStyle(color: AppColors.muted)),
    const SizedBox(height: 18),
    ...[
      ('I24H Focus', 'Hier · 58 min', Icons.mic_none_rounded),
      ('Paroles & enseignements', 'Lundi · 42 min', Icons.auto_stories_outlined),
      ('Le Grand Direct', 'Dimanche · 1 h 14', Icons.graphic_eq_rounded),
      ('La communauté I24H', 'Samedi · 36 min', Icons.groups_outlined),
    ].map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: I24HCard(child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.navy.withOpacity(.08), borderRadius: BorderRadius.circular(14)), child: Icon(r.$3, color: AppColors.navy)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)), const SizedBox(height: 4), Text(r.$2, style: const TextStyle(fontSize: 12, color: AppColors.muted))])), IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lecture de ${r.$1}'))), icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.navy, size: 30))]))),
  ]));
}
