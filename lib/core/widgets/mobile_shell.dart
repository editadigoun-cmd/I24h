import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../screens/mobile/home_screen.dart';
import '../../screens/mobile/programme_screen.dart';
import '../../screens/mobile/replay_screen.dart';
import '../../screens/mobile/donations_screen.dart';
import '../../screens/mobile/profile_screen.dart';

class MobileShell extends StatefulWidget {
  const MobileShell({super.key});
  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int index = 0;
  final pages = const [HomeScreen(), ProgrammeScreen(), ReplayScreen(), DonationsScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      backgroundColor: Colors.white,
      indicatorColor: AppColors.navy.withOpacity(.10),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
        NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Programme'),
        NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Replay'),
        NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Dons'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
      ],
    ),
  );
}
