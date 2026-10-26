import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import 'admin_planning_screen.dart';

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 720;
    return ListView(
      padding: EdgeInsets.fromLTRB(wide ? 28 : 18, 20, wide ? 28 : 18, 30),
      children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CENTRE DE CONTRÔLE', style: TextStyle(color: AppColors.blue, fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text('Vue d’ensemble', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 27)),
            const SizedBox(height: 5),
            const Text('Pilotez votre univers I24H.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
          ])),
          Container(width: 45, height: 45, decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white)),
        ]),
        const SizedBox(height: 23),
        Container(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.navy, Color(0xFF1C4779)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 27)),
            const SizedBox(width: 13),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ÉTAT DE LA DIFFUSION', style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
              SizedBox(height: 5),
              Text('Supervision I24H', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('État du flux à connecter au service de diffusion', style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.35)),
            ])),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('INDICATEURS', style: TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
        const SizedBox(height: 11),
        GridView.count(
          crossAxisCount: wide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: wide ? 1.45 : 1.35,
          children: const [
            _MetricCard(value: '24/7', label: 'Objectif de diffusion', icon: Icons.schedule_rounded, accent: AppColors.blue),
            _MetricCard(value: '—', label: 'Audience en direct', icon: Icons.people_alt_outlined, accent: AppColors.success),
            _MetricCard(value: '—', label: 'Émissions publiées', icon: Icons.play_circle_outline_rounded, accent: AppColors.gold),
            _MetricCard(value: '—', label: 'État du flux', icon: Icons.sensors_rounded, accent: AppColors.live),
          ],
        ),
        const SizedBox(height: 24),
        Row(children: [
          const Expanded(child: Text('Actions rapides', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -.3))),
          const Icon(Icons.bolt_rounded, color: AppColors.gold),
        ]),
        const SizedBox(height: 12),
        _ActionTile(icon: Icons.calendar_month_rounded, title: 'Gérer le programme', subtitle: 'Organiser les rendez-vous à l’antenne', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPlanningScreen()))),
        const SizedBox(height: 9),
        _ActionTile(icon: Icons.video_library_outlined, title: 'Émissions & replays', subtitle: 'Préparer et publier les contenus', onTap: () => _notice(context, 'Connectez la gestion des émissions à votre catalogue.')),
        const SizedBox(height: 9),
        _ActionTile(icon: Icons.groups_2_outlined, title: 'Animateurs', subtitle: 'Accéder à la gestion des équipes', onTap: () => _notice(context, 'La gestion des animateurs sera reliée aux données réelles.')),
        const SizedBox(height: 24),
        const Text('ACTIVITÉ RÉCENTE', style: TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
        const SizedBox(height: 11),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(20)),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline_rounded, color: AppColors.blue, size: 21),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Aucune activité connectée', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              SizedBox(height: 5),
              Text('Les événements apparaîtront ici après connexion aux services I24H.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.45)),
            ])),
          ]),
        ),
      ],
    );
  }

  static void _notice(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label, required this.icon, required this.accent});
  final String value;
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 35, height: 35, decoration: BoxDecoration(color: accent.withOpacity(.11), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: accent, size: 19)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.navy)),
      const SizedBox(height: 3),
      Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.muted, height: 1.25)),
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
        child: Row(children: [
          Container(width: 43, height: 43, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.blue)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ]),
      ),
    ),
  );
}
