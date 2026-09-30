import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class ProgrammeScreen extends StatefulWidget {
  const ProgrammeScreen({super.key});
  @override
  State<ProgrammeScreen> createState() => _ProgrammeScreenState();
}

class _ProgrammeScreenState extends State<ProgrammeScreen> {
  int day = 0;
  final days = const ['Aujourd’hui', 'Demain', 'Vendredi'];
  final shows = const [
    ('06:00', 'Réveil du Matin', '06:00 — 09:00', 'Edith A.'),
    ('09:00', 'I24H Focus', '09:00 — 12:00', 'Chadrac T.'),
    ('12:00', 'Pause Inspiration', '12:00 — 14:00', 'Ruth K.'),
    ('14:00', 'Le Grand Direct', '14:00 — 18:00', 'Paul D.'),
    ('18:00', 'Soirée I24H', '18:00 — 22:00', 'Équipe I24H'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Programme', style: TextStyle(fontWeight: FontWeight.w800))), body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 28), children: [
    SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: days.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(days[i]), selected: day == i, onSelected: (_) => setState(() => day = i)))),
    const SizedBox(height: 20),
    const Text('Aujourd’hui à l’antenne', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
    const SizedBox(height: 12),
    ...shows.map((s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: I24HCard(child: Row(children: [SizedBox(width: 54, child: Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)), const SizedBox(height: 3), Text('${s.$3} · ${s.$4}', style: const TextStyle(fontSize: 12, color: AppColors.muted))])), IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rappel activé pour ${s.$2}'))), icon: const Icon(Icons.notifications_none_rounded, color: AppColors.navy))]))),
  ]));
}
