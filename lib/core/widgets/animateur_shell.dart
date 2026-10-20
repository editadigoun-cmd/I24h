import 'package:flutter/material.dart';
import '../../screens/animateur/animateur_dashboard_content.dart';
import '../../screens/animateur/animateur_live_screen.dart';
import '../../screens/animateur/animateur_planning_screen.dart';
import '../../screens/animateur/animateur_replays_screen.dart';
import '../../screens/animateur/animateur_profile_screen.dart';
import '../theme/app_theme.dart';

class AnimateurShell extends StatefulWidget {
  const AnimateurShell({super.key});
  @override
  State<AnimateurShell> createState() => _AnimateurShellState();
}

class _AnimateurShellState extends State<AnimateurShell> {
  int index = 0;
  final pages = const [AnimateurDashboardContent(), AnimateurLiveScreen(), AnimateurPlanningScreen(), AnimateurReplaysScreen(), AnimateurProfileScreen()];
  final labels = const ['Vue d’ensemble', 'Studio de direct', 'Mon planning', 'Médias', 'Mon profil'];
  final icons = const [Icons.grid_view_rounded, Icons.sensors_rounded, Icons.calendar_month_rounded, Icons.library_music_rounded, Icons.person_rounded];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 76,
        title: Row(children: [
          if (!wide) const Padding(padding: EdgeInsets.only(right: 9), child: Icon(Icons.graphic_eq_rounded, color: AppColors.blue, size: 28)),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('I24H · Studio Animateur', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.ink)),
            SizedBox(height: 3),
            Text('Préparez et animez vos émissions', style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500)),
          ]),
        ]),
        actions: [
          if (wide) Container(margin: const EdgeInsets.symmetric(vertical: 18), padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: const Color(0xFFF1F5FC), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.circle, color: AppColors.success, size: 9), SizedBox(width: 8), Text('Studio prêt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink))])),
          IconButton(tooltip: 'Notifications', onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les notifications seront reliées au compte animateur.'))), icon: const Icon(Icons.notifications_none_rounded)),
          const Padding(padding: EdgeInsets.only(left: 4, right: 18), child: CircleAvatar(backgroundColor: AppColors.sky, child: Icon(Icons.mic_rounded, color: AppColors.blue))),
        ],
      ),
      body: Row(children: [
        if (wide) Container(width: 272, color: const Color(0xFF09172F), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(padding: const EdgeInsets.fromLTRB(24, 26, 20, 24), child: Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.blue, AppColors.cyan]), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 28)),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('I24H', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: 1)), Text('BROADCAST STUDIO', style: TextStyle(color: Color(0xFF91A5C7), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.4))]),
          ])),
          Padding(padding: const EdgeInsets.fromLTRB(24, 0, 16, 10), child: Text('MON ESPACE', style: TextStyle(color: Colors.white.withOpacity(.46), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
          Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 12), children: List.generate(labels.length, (i) {
            final selected = index == i;
            return Padding(padding: const EdgeInsets.only(bottom: 5), child: Material(color: selected ? const Color(0xFF1D3B6A) : Colors.transparent, borderRadius: BorderRadius.circular(13), child: InkWell(borderRadius: BorderRadius.circular(13), onTap: () => setState(() => index = i), child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), border: Border.all(color: selected ? const Color(0xFF315D9A) : Colors.transparent)),
              child: Row(children: [Icon(icons[i], color: selected ? const Color(0xFF80D9FF) : const Color(0xFFB5C3DA), size: 21), const SizedBox(width: 13), Expanded(child: Text(labels[i], style: TextStyle(color: selected ? Colors.white : const Color(0xFFD1DBEA), fontSize: 14, fontWeight: selected ? FontWeight.w800 : FontWeight.w600))), if (selected) Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle))]),
            ))));
          }))),
          Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(.08))), child: const Row(children: [Icon(Icons.headphones_rounded, color: AppColors.cyan, size: 22), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Studio I24H', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)), SizedBox(height: 3), Text('Prêt pour votre direct', style: TextStyle(color: Color(0xFF91A5C7), fontSize: 11))]))])),
        ])),
        Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: KeyedSubtree(key: ValueKey(index), child: pages[index]))),
      ]),
      bottomNavigationBar: !wide ? NavigationBar(height: 72, selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Accueil'),
        NavigationDestination(icon: Icon(Icons.sensors_rounded), label: 'Direct'),
        NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: 'Planning'),
        NavigationDestination(icon: Icon(Icons.library_music_rounded), label: 'Médias'),
        NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profil'),
      ]) : null,
    );
  }
}
