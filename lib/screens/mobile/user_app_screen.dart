import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class UserAppScreen extends StatefulWidget {
  const UserAppScreen({super.key});
  @override
  State<UserAppScreen> createState() => _UserAppScreenState();
}

class _UserAppScreenState extends State<UserAppScreen> {
  int _index = 0;
  bool _playing = false;

  final _titles = const ['Accueil', 'Programme', 'Replay', 'Intentions', 'Profil'];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      _programme(),
      _replay(),
      _intentions(),
      _profile(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index], style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _notice('Aucune nouvelle notification'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Programme'),
          NavigationDestination(icon: Icon(Icons.history_rounded), selectedIcon: Icon(Icons.history_toggle_off_rounded), label: 'Replay'),
          NavigationDestination(icon: Icon(Icons.favorite_outline_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Intentions'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _home() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
    children: [
      _brand(),
      const SizedBox(height: 22),
      const Text('Bonjour 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Votre radio, votre foi, votre communauté.', style: TextStyle(color: AppColors.muted, fontSize: 15)),
      const SizedBox(height: 22),
      _liveCard(),
      const SizedBox(height: 20),
      const Text('À la une', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      _actionCard(Icons.calendar_month_rounded, 'Programme du jour', 'Découvrez les prochaines émissions', () => setState(() => _index = 1)),
      const SizedBox(height: 10),
      _actionCard(Icons.favorite_rounded, 'Exprimer une intention', 'Partagez votre intention avec la communauté', () => setState(() => _index = 3)),
      const SizedBox(height: 10),
      _actionCard(Icons.history_rounded, 'Réécouter', 'Retrouvez les émissions disponibles', () => setState(() => _index = 2)),
    ],
  );

  Widget _brand() => Row(children: [
    Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.graphic_eq_rounded, color: Colors.white)),
    const SizedBox(width: 12),
    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('I24H', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.navy)),
      Text('La voix qui vous accompagne', style: TextStyle(fontSize: 12, color: AppColors.muted)),
    ]),
  ]);

  Widget _liveCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 9, height: 9, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        const Text('EN DIRECT', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
        const Spacer(),
        const Text('24/7', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 18),
      const Text('I24H — La radio en continu', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Écoutez le direct depuis votre téléphone.', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 18),
      FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy),
        onPressed: () => setState(() => _playing = !_playing),
        icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
        label: Text(_playing ? 'Mettre en pause' : 'Écouter maintenant'),
      ),
    ]),
  );

  Widget _actionCard(IconData icon, String title, String subtitle, VoidCallback onTap) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.blue)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ]),
      ),
    ),
  );

  Widget _programme() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text('Aujourd’hui', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      _schedule('06:00', 'Réveil spirituel', '06:00 — 08:00'),
      _schedule('09:00', 'La matinale I24H', '09:00 — 12:00'),
      _schedule('13:00', 'Parole & communauté', '13:00 — 15:00'),
      _schedule('18:00', 'Temps de prière', '18:00 — 19:00'),
    ],
  );

  Widget _schedule(String time, String title, String duration) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(width: 58, height: 58, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)), child: Text(time, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.blue))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(duration, style: const TextStyle(color: AppColors.muted)),
      trailing: IconButton(onPressed: () => _notice('Rappel activé pour $title'), icon: const Icon(Icons.notifications_none_rounded)),
    ),
  );

  Widget _replay() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text('Dernières émissions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      _replayTile('La matinale I24H', 'Aujourd’hui • 09:00', Icons.mic_rounded),
      _replayTile('Parole & communauté', 'Hier • 13:00', Icons.groups_rounded),
      _replayTile('Temps de prière', 'Hier • 18:00', Icons.favorite_rounded),
    ],
  );

  Widget _replayTile(String title, String subtitle, IconData icon) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: Colors.white)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: IconButton(onPressed: () => _notice('Lecture de $title'), icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.blue)),
    ),
  );

  Widget _intentions() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text('Vos intentions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Déposez une intention et confiez-la à la prière.', style: TextStyle(color: AppColors.muted)),
      const SizedBox(height: 20),
      FilledButton.icon(onPressed: _addIntention, icon: const Icon(Icons.add_rounded), label: const Text('Déposer une intention')),
      const SizedBox(height: 18),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.favorite_rounded, color: AppColors.blue)),
        const SizedBox(width: 14),
        const Expanded(child: Text('Aucune intention récente. Vous pouvez en déposer une à tout moment.')),
      ]))),
    ],
  );

  Widget _profile() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Center(child: Container(width: 82, height: 82, decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: Colors.white, size: 42))),
      const SizedBox(height: 14),
      const Center(child: Text('Utilisateur I24H', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
      const SizedBox(height: 24),
      _profileItem(Icons.notifications_none_rounded, 'Notifications', () => _notice('Préférences de notifications')),
      _profileItem(Icons.favorite_border_rounded, 'Mes intentions', () => setState(() => _index = 3)),
      _profileItem(Icons.info_outline_rounded, 'À propos de I24H', () => _notice('I24H — La voix qui vous accompagne')),
      _profileItem(Icons.logout_rounded, 'Se déconnecter', () => _notice('Déconnexion disponible lorsque le compte sera connecté')),
    ],
  );

  Widget _profileItem(IconData icon, String label, VoidCallback onTap) => Card(child: ListTile(onTap: onTap, leading: Icon(icon, color: AppColors.blue), title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: const Icon(Icons.chevron_right_rounded)));

  void _addIntention() {
    final controller = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Nouvelle intention'),
      content: TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(hintText: 'Écrivez votre intention…')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(onPressed: () { Navigator.pop(context); _notice('Votre intention a été enregistrée.'); }, child: const Text('Envoyer')),
      ],
    ));
  }

  void _notice(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
