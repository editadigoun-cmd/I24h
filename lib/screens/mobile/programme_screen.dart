import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

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
  Widget build(BuildContext context) {
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
      const Text('Programme', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Retrouvez les émissions de la journée.', style: TextStyle(color: AppColors.muted)),
      const SizedBox(height: 20),
      SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: days.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(days[i]), selected: day == i, onSelected: (_) => setState(() => day = i)))),
      const SizedBox(height: 22),
      const Text('Aujourd’hui à l’antenne', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      ...shows.map((s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [Container(width: 58, height: 58, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)), child: Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.blue))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text('${s.$3} · ${s.$4}', style: const TextStyle(fontSize: 12, color: AppColors.muted))])), IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rappel activé pour ${s.$2}'))), icon: const Icon(Icons.notifications_none_rounded, color: AppColors.navy))])))),
    ]));
  }
}
