import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/i24h_config.dart';
import '../../core/services/i24h_backend.dart';
import 'donations_screen.dart';
import '../../core/theme/app_theme.dart';
import 'home_screen.dart';
import 'live_player_screen.dart';

class UserAppScreen extends StatefulWidget {
  const UserAppScreen({super.key});
  @override
  State<UserAppScreen> createState() => _UserAppScreenState();
}

class _UserAppScreenState extends State<UserAppScreen> {
  int tab = 0;
  bool playing = false;
  bool notifications = true;

  late Future<List<Map<String, dynamic>>> _programsFuture;
  late Future<List<Map<String, dynamic>>> _replaysFuture;
  late Future<List<Map<String, dynamic>>> _intentionsFuture;

  @override
  void initState() {
    super.initState();
    _programsFuture = I24HBackend.publishedPrograms();
    _replaysFuture = I24HBackend.publishedReplays();
    _intentionsFuture = I24HBackend.myPrayerIntentions();
  }

  final titles = const ['Accueil', 'Programme', 'Replay', 'Intentions', 'Profil'];

  @override
  Widget build(BuildContext context) {
    final pages = [const HomeScreen(), _program(), _replay(), _intentions(), _profile(context)];
    return Scaffold(
      appBar: tab == 0 ? null : AppBar(
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

  Widget _program() => FutureBuilder<List<Map<String, dynamic>>>(
        future: _programsFuture,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Programme', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Les rendez-vous publiés par I24H.', style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                _emptyMessage('Impossible de charger le programme. Vérifiez votre connexion.')
              else if (items.isEmpty)
                _emptyMessage('Aucun programme publié pour le moment.')
              else
                ...items.map((item) {
                  final start = DateTime.tryParse('${item['starts_at'] ?? ''}')?.toLocal();
                  final end = DateTime.tryParse('${item['ends_at'] ?? ''}')?.toLocal();
                  final time = start == null ? 'Horaire à préciser' : '${_time(start)}${end == null ? '' : ' — ${_time(end)}'}';
                  final presenter = '${item['presenter'] ?? ''}'.toString().trim();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today_rounded, color: AppColors.blue),
                      title: Text('${item['title'] ?? 'Émission I24H'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(presenter.isEmpty ? time : '$time · $presenter'),
                    ),
                  );
                }),
            ],
          );
        },
      );

  Widget _replay() {
    final rawCatalog = I24HConfig.replayCatalogJson.trim();
    if (!I24HConfig.backendReady && rawCatalog.isNotEmpty) {
      List<Map<String, String>> localItems = [];
      try {
        final decoded = jsonDecode(rawCatalog);
        if (decoded is List) {
          localItems = decoded.whereType<Map>().map((entry) => {
            'title': (entry['title'] ?? '').toString(),
            'subtitle': (entry['subtitle'] ?? 'Replay I24H').toString(),
            'url': (entry['url'] ?? '').toString(),
          }).where((entry) => entry['title']!.trim().isNotEmpty).toList();
        }
      } on FormatException {
        localItems = [];
      }
      return _replayList(localItems.map((item) => <String, dynamic>{...item, 'local_url': item['url']}).toList(), local: true);
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _replaysFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return _emptyMessage('Impossible de charger les replays. Vérifiez votre connexion.');
        return _replayList(snapshot.data ?? []);
      },
    );
  }

  Widget _replayList(List<Map<String, dynamic>> items, {bool local = false}) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Replay', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(local ? 'Catalogue de test local' : 'Réécoutez les émissions publiées par I24H.', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          if (items.isEmpty)
            _emptyMessage(local ? 'Le catalogue de test est vide ou invalide.' : 'Le catalogue Replay arrive bientôt.'),
          ...items.map((item) => Card(
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.graphic_eq_rounded, color: AppColors.blue),
                  ),
                  title: Text('${item['title'] ?? 'Replay I24H'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${item['subtitle'] ?? item['description'] ?? 'Replay I24H'}'),
                  trailing: IconButton(
                    onPressed: () => _playReplay(item, local: local),
                    icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.blue, size: 30),
                  ),
                ),
              )),
        ],
      );

  Future<void> _playReplay(Map<String, dynamic> item, {required bool local}) async {
    try {
      final String url;
      if (local) {
        url = '${item['local_url'] ?? item['url'] ?? ''}'.toString().trim();
      } else {
        final path = '${item['media_path'] ?? ''}'.toString().trim();
        if (path.isEmpty) {
          _snack('Le fichier audio de ce replay n’est pas configuré.');
          return;
        }
        url = await I24HBackend.replaySignedUrl(path);
      }
      if (url.isEmpty) {
        _snack('Le lien de ce replay n’est pas disponible.');
        return;
      }
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => LivePlayerScreen(
          title: '${item['title'] ?? 'Replay I24H'}',
          subtitle: '${item['subtitle'] ?? item['description'] ?? 'Replay I24H'}',
          isLive: false,
          audioUrl: url,
        ),
      ));
    } catch (_) {
      _snack('Impossible d’ouvrir ce replay. Vérifiez le fichier et les autorisations.');
    }
  }

  Widget _intentions() => FutureBuilder<List<Map<String, dynamic>>>(
        future: _intentionsFuture,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Intentions', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Un espace privé pour déposer vos demandes de prière.', style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add_rounded), label: const Text('Déposer une intention')),
              ),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                _emptyMessage('Impossible de charger vos intentions. Vérifiez votre connexion.')
              else if (items.isEmpty)
                _emptyMessage('Vos intentions envoyées apparaîtront ici.')
              else
                ...items.map((item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.favorite_rounded, color: AppColors.blue),
                    title: Text('${item['message'] ?? ''}'),
                    subtitle: Text('Statut : ${_statusLabel('${item['status'] ?? 'received'}')}'),
                  ),
                )),
            ],
          );
        },
      );

  Widget _profile(BuildContext context) {
    final user = I24HConfig.backendReady ? Supabase.instance.client.auth.currentUser : null;
    final fullName = '${user?.userMetadata?['full_name'] ?? ''}'.trim();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: Container(width: 86, height: 86, decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: Colors.white, size: 44))),
        const SizedBox(height: 14),
        Center(child: Text(fullName.isEmpty ? 'Mon espace I24H' : fullName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))),
        if (user?.email != null) ...[const SizedBox(height: 5), Center(child: Text(user!.email!, style: const TextStyle(color: AppColors.muted)))],
        const SizedBox(height: 26),
        _setting(Icons.favorite_outline_rounded, 'Soutenir I24H', () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DonationsScreen()))),
        _setting(Icons.notifications_none_rounded, 'Notifications', _notifications),
        _setting(Icons.info_outline_rounded, 'À propos de I24H', _about),
        _setting(Icons.help_outline_rounded, 'Aide & assistance', _help),
        _setting(Icons.shield_outlined, 'Confidentialité', _privacy),
        _setting(Icons.logout_rounded, 'Se déconnecter', _signOut),
      ],
    );
  }

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

  Future<void> _add() async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déposer une intention'),
        content: TextField(controller: controller, maxLines: 5, maxLength: 3000, decoration: const InputDecoration(hintText: 'Votre intention…')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: const Text('Envoyer')),
        ],
      ),
    );
    controller.dispose();
    if (message == null || message.trim().isEmpty) return;
    try {
      await I24HBackend.submitPrayerIntention(message);
      if (!mounted) return;
      setState(() => _intentionsFuture = I24HBackend.myPrayerIntentions());
      _snack('Votre intention a été envoyée en toute confidentialité.');
    } on PostgrestException catch (error) {
      _snack(error.message);
    } catch (error) {
      _snack(error is ArgumentError || error is StateError
          ? error.toString().replaceFirst('Bad state: ', '')
          : 'Impossible d’envoyer votre intention. Vérifiez votre connexion.');
    }
  }

  Widget _emptyMessage(String message) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.4)),
        ),
      );

  String _time(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  String _statusLabel(String status) => switch (status) {
        'received' => 'Reçue',
        'in_prayer' => 'En prière',
        'answered' => 'Exaucée',
        'archived' => 'Archivée',
        _ => status,
      };

  Future<void> _signOut() async {
    try {
      await I24HBackend.signOut();
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (_) {
      _snack('Impossible de fermer la session. Réessayez.');
    }
  }

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
