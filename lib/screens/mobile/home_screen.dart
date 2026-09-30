import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            sliver: SliverList(delegate: SliverChildListDelegate([
              Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.graphic_eq, color: Colors.white)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('I24H', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.navy)), Text('La voix qui vous accompagne', style: TextStyle(fontSize: 12, color: AppColors.muted))])),
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
              ]),
              const SizedBox(height: 28),
              const Text('Bonjour 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 6),
              const Text('Retrouvez votre radio, vos émissions et votre communauté.', style: TextStyle(color: AppColors.muted, fontSize: 15)),
              const SizedBox(height: 22),
              Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)), const SizedBox(width: 8), const Text('EN DIRECT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.red)), const Spacer(), const Text('24/7', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.muted))]),
                const SizedBox(height: 14),
                const Text('I24H — La radio en continu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Écoutez le direct et restez connecté à votre communauté.', style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 18),
                FilledButton.icon(onPressed: () => _showPlayer(context), icon: const Icon(Icons.play_arrow_rounded), label: const Text('Écouter maintenant')),
              ]))),
              const SizedBox(height: 18),
              Row(children: [const Expanded(child: Text('À la une', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))), TextButton(onPressed: () {}, child: const Text('Voir tout'))]),
              const SizedBox(height: 10),
              _Feature(title: 'Votre programme du jour', subtitle: 'Découvrez les prochaines émissions', icon: Icons.calendar_today_rounded, onTap: () {}),
              const SizedBox(height: 10),
              _Feature(title: 'Exprimez une intention', subtitle: 'Partagez votre intention avec la communauté', icon: Icons.favorite_outline_rounded, onTap: () {}),
            ])),
          )
        ],
      ),
    );
  }

  void _showPlayer(BuildContext context) {
    showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => const Padding(padding: EdgeInsets.fromLTRB(24, 8, 24, 30), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('I24H — Direct', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), SizedBox(height: 8), Text('Lecteur audio prêt. La connexion au flux sera branchée dans la prochaine étape.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)), SizedBox(height: 20), Icon(Icons.graphic_eq_rounded, size: 64, color: AppColors.blue)])));
  }
}

class _Feature extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _Feature({required this.title, required this.subtitle, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.blue)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 13))])), const Icon(Icons.chevron_right_rounded, color: AppColors.muted)]))));
}
