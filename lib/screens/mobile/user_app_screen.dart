import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class UserAppScreen extends StatefulWidget {
  const UserAppScreen({super.key});
  @override
  State<UserAppScreen> createState() => _UserAppScreenState();
}

class _UserAppScreenState extends State<UserAppScreen> {
  int tab = 0;
  bool playing = false;
  bool notifications = true;

  final titles = const ['Accueil', 'Programme', 'Replay', 'Intentions', 'Profil'];

  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _program(), _replay(), _intentions(), _profile(context)];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[tab], style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: _notifications,
            icon: Badge(
              isLabelVisible: notifications,
              smallSize: 8,
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Programme'),
          NavigationDestination(icon: Icon(Icons.replay_outlined), selectedIcon: Icon(Icons.replay_rounded), label: 'Replay'),
          NavigationDestination(icon: Icon(Icons.favorite_outline_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Intentions'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _home() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          Row(
            children: [
              const Text('I24H', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: 1.5)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(20)),
                child: const Text('24/7', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text('Votre univers I24H', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -.8)),
          const SizedBox(height: 8),
          const Text('La voix qui vous accompagne, où que vous soyez.', style: TextStyle(color: AppColors.muted, fontSize: 15)),
          const SizedBox(height: 24),
          _live(),
          const SizedBox(height: 26),
          const Text('Accès rapide', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _tile(Icons.calendar_month_rounded, 'Programme', 'Vos émissions du jour', () => setState(() => tab = 1)),
          _tile(Icons.replay_rounded, 'Replay', 'Réécoutez vos rendez-vous', () => setState(() => tab = 2)),
          _tile(Icons.favorite_rounded, 'Intentions', 'Confiez votre prière', () => setState(() => tab = 3)),
        ],
      );

  Widget _live() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.navy, Color(0xFF173E72)]),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text('EN DIRECT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const Spacer(),
                const Icon(Icons.graphic_eq_rounded, color: AppColors.gold),
              ],
            ),
            const SizedBox(height: 20),
            const Text('I24H — La radio en continu', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Une présence, une parole, un moment.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy),
                onPressed: () => setState(() => playing = !playing),
                icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                label: Text(playing ? 'Pause' : 'Écouter le direct'),
              ),
            ),
          ],
        ),
      );

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback tap) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          child: ListTile(
            onTap: tap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: AppColors.blue),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
      );

  Widget _program() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Programme', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Les rendez-vous I24H de la journée', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          ...['06:00  Réveil spirituel', '09:00  La matinale I24H', '13:00  Parole & communauté', '18:00  Temps de prière', '21:00  Veillée I24H']
              .map((x) => Card(
                    child: ListTile(
                      title: Text(x, style: const TextStyle(fontWeight: FontWeight.w700)),
                      trailing: IconButton(onPressed: () => _snack('Rappel activé'), icon: const Icon(Icons.notifications_none_rounded)),
                    ),
                  )),
        ],
      );

  Widget _replay() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Replay', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          ...['La matinale I24H', 'Parole & communauté', 'Temps de prière', 'Veillée I24H']
              .map((x) => Card(
                    child: ListTile(
                      title: Text(x, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: const Text('Disponible à la réécoute'),
                      trailing: IconButton(onPressed: () => _snack('Lecture lancée'), icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.blue)),
                    ),
                  )),
        ],
      );

  Widget _intentions() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Intentions', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Un espace confidentiel pour déposer ce qui vous tient à cœur.', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add_rounded), label: const Text('Déposer une intention')),
          ),
          const SizedBox(height: 18),
          const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Vos intentions apparaîtront ici.'))),
        ],
      );

  Widget _profile(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(height: 14),
          const Center(child: Text('Mon espace I24H', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900))),
          const SizedBox(height: 26),
          _setting(Icons.notifications_none_rounded, 'Notifications', _notifications),
          _setting(Icons.info_outline_rounded, 'À propos de I24H', _about),
          _setting(Icons.help_outline_rounded, 'Aide & assistance', _help),
          _setting(Icons.shield_outlined, 'Confidentialité', _privacy),
          _setting(Icons.logout_rounded, 'Se déconnecter', () => Navigator.pushReplacementNamed(context, '/login')),
        ],
      );

  Widget _setting(IconData icon, String title, VoidCallback action) => Card(
        child: ListTile(
          onTap: action,
          leading: Icon(icon, color: AppColors.blue),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );

  void _notifications() {
    setState(() => notifications = false);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Notifications', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              SizedBox(height: 18),
              ListTile(leading: Icon(Icons.radio, color: AppColors.blue), title: Text('I24H est en direct'), subtitle: Text('Écoutez maintenant')),
              ListTile(leading: Icon(Icons.calendar_month, color: AppColors.blue), title: Text('Votre programme vous attend'), subtitle: Text('Consultez les rendez-vous du jour')),
            ],
          ),
        ),
      ),
    );
  }

  void _about() => _sheet('À propos de I24H', 'I24H — La voix qui vous accompagne. Une expérience radio, prière et communauté pensée pour rester simple, élégante et humaine. Version 1.0.0');

  void _help() => _sheet('Aide & assistance', 'Besoin d’aide ? Consultez la FAQ, contactez notre équipe ou signalez un problème depuis votre espace.');

  void _privacy() => _sheet('Confidentialité', 'Vos données doivent rester sous votre contrôle. Les réglages de confidentialité seront disponibles dans votre espace compte.');

  void _sheet(String title, String body) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(body, style: const TextStyle(color: AppColors.muted, height: 1.5)),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))),
          ],
        ),
      ),
    );
  }

  void _add() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déposer une intention'),
        content: TextField(controller: controller, maxLines: 5, decoration: const InputDecoration(hintText: 'Votre intention…')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _snack('Votre intention a été enregistrée.');
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
