import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/i24h_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
    SliverAppBar(
      floating: true,
      title: Row(children: [const I24HLogo(size: 38), const SizedBox(width: 10), const Text('I24H', style: TextStyle(fontWeight: FontWeight.w800))]),
      actions: [IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune nouvelle notification'))), icon: const Icon(Icons.notifications_none_rounded))],
    ),
    SliverPadding(padding: const EdgeInsets.fromLTRB(18, 10, 18, 28), sliver: SliverList(delegate: SliverChildListDelegate([
      I24HCard(
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(18), decoration: const BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.vertical(top: Radius.circular(18))), child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: const I24HIcon('direct', size: 23, color: Colors.white)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('EN DIRECT', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.2)), SizedBox(height: 3), Text('I24H Radio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20))])),
            const StatusPill(label: 'ON AIR', color: AppColors.gold),
          ])),
          Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('La voix qui vous accompagne 24/7', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink)),
            const SizedBox(height: 5),
            const Text('Programme en cours · Musique & inspiration', style: TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lecture du direct démarrée'))), icon: const Icon(Icons.play_arrow_rounded), label: const Text('Écouter'))),
              const SizedBox(width: 9),
              Expanded(child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Direct partagé'))), icon: const Icon(Icons.share_outlined), label: const Text('Partager'))),
            ]),
          ])),
        ]),
      ),
      const SizedBox(height: 22),
      const SectionTitle(title: 'Votre prochain rendez-vous'),
      I24HCard(child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.gold.withOpacity(.14), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.schedule_rounded, color: AppColors.gold)), const SizedBox(width: 13), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Réveil du Matin', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)), SizedBox(height: 4), Text('Aujourd’hui · 06:00 — 09:00', style: TextStyle(color: AppColors.muted, fontSize: 12))])), const Icon(Icons.chevron_right_rounded, color: AppColors.muted)])),
      const SizedBox(height: 22),
      const SectionTitle(title: 'Exprimez votre intention'),
      I24HCard(child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.gold.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: const I24HIcon('coeur', color: AppColors.navy, size: 23)), const SizedBox(width: 13), const Expanded(child: Text('Déposez une intention de prière et rejoignez la communauté.', style: TextStyle(color: AppColors.muted, height: 1.45))), const SizedBox(width: 6), IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Formulaire d’intention ouvert'))), icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.navy))])),
      const SizedBox(height: 22),
      const SectionTitle(title: 'À découvrir'),
      SizedBox(height: 130, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 3, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => SizedBox(width: 220, child: I24HCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon([Icons.headphones_rounded, Icons.groups_rounded, Icons.auto_stories_rounded][i], color: AppColors.navy), const Spacer(), Text(['Les podcasts I24H', 'La communauté', 'Paroles & enseignements'][i], style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), const Text('Découvrir', style: TextStyle(color: AppColors.muted, fontSize: 11))])))),
    ])))
  ]);
}
