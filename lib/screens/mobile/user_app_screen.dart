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
  int selectedDay = 0;

  final titles = const ['Accueil', 'Programme', 'Replay', 'Intentions', 'Profil'];

  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _program(), _replay(), _intentions(), _profile(context)];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.navySoft],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 23),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('I24H', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.navy)),
                Text('LA VOIX QUI VOUS ACCOMPAGNE', style: TextStyle(fontSize: 8, letterSpacing: .7, fontWeight: FontWeight.w700, color: AppColors.muted)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _notifications,
            tooltip: 'Notifications',
            icon: Badge(
              isLabelVisible: notifications,
              smallSize: 8,
              child: const Icon(Icons.notifications_none_rounded, size: 25),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: IndexedStack(index: tab, children: pages)),
          if (playing) _miniPlayer(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Programme'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline_rounded), selectedIcon: Icon(Icons.play_circle_fill_rounded), label: 'Replay'),
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Intentions'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _home() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const SizedBox(height: 8),
          const Text('VOTRE RENDEZ-VOUS MÉDIA', style: TextStyle(fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w900, color: AppColors.blue)),
          const SizedBox(height: 8),
          const Text('Toute l’émotion.\nEn direct.', style: TextStyle(fontSize: 34, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -1.2, color: AppColors.navy)),
          const SizedBox(height: 10),
          const Text('La voix qui vous accompagne, où que vous soyez.', style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.45)),
          const SizedBox(height: 22),
          _liveHero(),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(child: Text('À l’antenne', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.4))),
              TextButton(onPressed: () => setState(() => tab = 1), child: const Text('Le programme')),
            ],
          ),
          const SizedBox(height: 4),
          _scheduleTile('09:00', 'I24H Focus', 'Information · Échanges', Icons.mic_none_rounded, false),
          const SizedBox(height: 10),
          _scheduleTile('13:00', 'Parole & communauté', 'Foi · Témoignages', Icons.auto_awesome_outlined, true),
          const SizedBox(height: 26),
          Row(
            children: [
              const Expanded(child: Text('À revoir', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.4))),
              TextButton(onPressed: () => setState(() => tab = 2), child: const Text('Tous les replays')),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 164,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _replayCard('PAROLES & ENSEIGNEMENTS', 'Trouver la paix au quotidien', const Color(0xFF203B67), Icons.spa_rounded),
                const SizedBox(width: 12),
                _replayCard('LA COMMUNAUTÉ', 'Des voix, des histoires', const Color(0xFF4B386D), Icons.groups_rounded),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9EC),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF0E4C7)),
            ),
            child: Row(
              children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.gold.withOpacity(.2), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.favorite_rounded, color: AppColors.navy)),
                const SizedBox(width: 13),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('I24H, c’est aussi votre communauté', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
                  SizedBox(height: 4),
                  Text('Déposez une intention et partagez ce qui compte.', style: TextStyle(fontSize: 12, height: 1.35, color: AppColors.muted)),
                ])),
                IconButton(onPressed: () => setState(() => tab = 3), icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.navy)),
              ],
            ),
          ),
        ],
      );

  Widget _liveHero() => Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF071326), Color(0xFF12386A), Color(0xFF1769A5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(.16), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.live, borderRadius: BorderRadius.circular(8)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.circle, size: 7, color: Colors.white),
                    SizedBox(width: 6),
                    Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                  ]),
                ),
                const Spacer(),
                const Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 25),
                const SizedBox(width: 6),
                const Text('I24H RADIO', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 23),
            const Text('La radio en continu', style: TextStyle(color: Colors.white, fontSize: 23, height: 1.15, fontWeight: FontWeight.w900, letterSpacing: -.5)),
            const SizedBox(height: 7),
            const Text('Une présence, une parole, un moment.', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 19),
            _waveform(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  setState(() => playing = !playing);
                  if (playing) _openPlayer();
                },
                icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 24),
                label: Text(playing ? 'Lecture en cours' : 'Écouter le direct', style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 11),
            const Center(child: Text('Lecteur visuel · connexion au flux à intégrer', style: TextStyle(color: Colors.white54, fontSize: 10))),
          ],
        ),
      );

  Widget _waveform() {
    const heights = [9.0, 17.0, 12.0, 25.0, 15.0, 31.0, 19.0, 12.0, 26.0, 35.0, 17.0, 27.0, 13.0, 22.0, 31.0, 15.0, 9.0, 24.0, 18.0, 29.0, 12.0, 20.0, 34.0, 16.0, 10.0, 23.0, 14.0, 27.0, 18.0, 11.0, 30.0, 20.0];
    return SizedBox(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: heights.map((h) => Container(
          width: 3,
          height: h,
          decoration: BoxDecoration(color: AppColors.gold.withOpacity(.45 + (h / 70)), borderRadius: BorderRadius.circular(4)),
        )).toList(),
      ),
    );
  }

  Widget _scheduleTile(String time, String title, String subtitle, IconData icon, bool active) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: active ? AppColors.blue.withOpacity(.35) : AppColors.line)),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: active ? AppColors.sky : const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: active ? AppColors.blue : AppColors.navySoft)),
            const SizedBox(width: 12),
            SizedBox(width: 48, child: Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.blue))),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ])),
            if (active) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(8)), child: const Text('EN COURS', style: TextStyle(fontSize: 8, color: AppColors.blue, fontWeight: FontWeight.w900))),
          ],
        ),
      );

  Widget _replayCard(String category, String title, Color color, IconData icon) => SizedBox(
        width: 235,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(.72)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon, color: Colors.white.withOpacity(.9), size: 24), const Spacer(), const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 30)]),
            const Spacer(),
            Text(category, style: const TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.15, fontWeight: FontWeight.w900)),
          ]),
        ),
      );

  Widget _program() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          const Text('Le programme', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.7)),
          const SizedBox(height: 6),
          const Text('Les rendez-vous qui rythment votre journée.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 20),
          SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal, children: [
            _dayChip('Aujourd’hui', 0), const SizedBox(width: 8),
            _dayChip('Demain', 1), const SizedBox(width: 8),
            _dayChip('Vendredi', 2),
          ])),
          const SizedBox(height: 22),
          const Text('À l’antenne et à venir', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 13),
          _programItem('06:00', 'Réveil spirituel', 'Prière · Inspiration', Icons.wb_twilight_rounded, true),
          _programItem('09:00', 'I24H Focus', 'Actualités · Décryptage', Icons.mic_none_rounded, false),
          _programItem('13:00', 'Parole & communauté', 'Témoignages · Échanges', Icons.groups_rounded, false),
          _programItem('18:00', 'Temps de prière', 'Recueillement · Prière', Icons.spa_rounded, false),
          _programItem('21:00', 'Veillée I24H', 'La nuit en communauté', Icons.nightlight_round, false),
          const SizedBox(height: 10),
          const Text('Les horaires affichés sont des exemples tant que le programme réel n’est pas connecté.', style: TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      );

  Widget _dayChip(String label, int index) => ChoiceChip(
        label: Text(label),
        selected: selectedDay == index,
        onSelected: (_) => setState(() => selectedDay = index),
        selectedColor: AppColors.sky,
        backgroundColor: Colors.white,
        side: BorderSide(color: selectedDay == index ? AppColors.blue.withOpacity(.25) : AppColors.line),
        labelStyle: TextStyle(color: selectedDay == index ? AppColors.blue : AppColors.muted, fontWeight: FontWeight.w800, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      );

  Widget _programItem(String time, String title, String subtitle, IconData icon, bool now) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: now ? AppColors.blue.withOpacity(.35) : AppColors.line)),
          child: Row(children: [
            SizedBox(width: 48, child: Text(time, style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w900, fontSize: 12))),
            const SizedBox(width: 10),
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.blue)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            ])),
            IconButton(onPressed: () => _snack('Rappel : fonctionnalité à connecter aux notifications.'), icon: const Icon(Icons.notifications_none_rounded, color: AppColors.muted)),
          ]),
        ),
      );

  Widget _replay() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          const Text('À réécouter', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.7)),
          const SizedBox(height: 6),
          const Text('Retrouvez les émissions qui vous ont marqué.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 18),
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une émission',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.line)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.line)),
            ),
          ),
          const SizedBox(height: 18),
          _replayListItem('I24H Focus', 'Hier · 58 min', const Color(0xFF203B67), Icons.mic_none_rounded),
          _replayListItem('Paroles & enseignements', 'Lundi · 42 min', const Color(0xFF4B386D), Icons.auto_stories_outlined),
          _replayListItem('Le Grand Direct', 'Dimanche · 1 h 14', const Color(0xFF175D72), Icons.graphic_eq_rounded),
          _replayListItem('La communauté I24H', 'Samedi · 36 min', const Color(0xFF784B3C), Icons.groups_outlined),
          const SizedBox(height: 6),
          const Text('Les contenus ci-dessus sont des maquettes visuelles. Les fichiers audio et leurs métadonnées restent à intégrer.', style: TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      );

  Widget _replayListItem(String title, String subtitle, Color color, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line)),
          child: Row(children: [
            Container(width: 64, height: 68, decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(.7)]), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: Colors.white, size: 28)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              const SizedBox(height: 7),
              const Text('ÉMISSION I24H', style: TextStyle(color: AppColors.blue, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .8)),
            ])),
            IconButton(onPressed: () => _snack('Le lecteur audio réel reste à connecter.'), icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.blue, size: 31)),
          ]),
        ),
      );

  Widget _intentions() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          const Text('Votre espace de prière', style: TextStyle(fontSize: 28, height: 1.1, fontWeight: FontWeight.w900, letterSpacing: -.7)),
          const SizedBox(height: 8),
          const Text('Un espace bienveillant pour partager ce qui vous tient à cœur.', style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4)),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.navy, Color(0xFF1C4779)]), borderRadius: BorderRadius.circular(24)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.favorite_rounded, color: AppColors.gold, size: 30),
              SizedBox(height: 14),
              Text('Vous n’êtes pas seul.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              SizedBox(height: 8),
              Text('Déposez votre intention. Elle pourra être portée en prière par la communauté I24H.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45)),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 54, child: FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add_rounded), label: const Text('Déposer une intention'))),
          const SizedBox(height: 22),
          const Text('Vos intentions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line)),
            child: const Column(children: [
              Icon(Icons.volunteer_activism_outlined, color: AppColors.blue, size: 34),
              SizedBox(height: 10),
              Text('Votre espace est prêt', style: TextStyle(fontWeight: FontWeight.w800)),
              SizedBox(height: 5),
              Text('Vos intentions apparaîtront ici après connexion au service.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4)),
            ]),
          ),
        ],
      );

  Widget _profile(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          const Text('Mon espace', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.7)),
          const SizedBox(height: 6),
          const Text('Personnalisez votre expérience I24H.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navySoft]), borderRadius: BorderRadius.circular(24)),
            child: const Row(children: [
              CircleAvatar(radius: 29, backgroundColor: Colors.white24, child: Icon(Icons.person_rounded, color: Colors.white, size: 31)),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bienvenue sur I24H', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                SizedBox(height: 5),
                Text('Connectez-vous pour personnaliser votre espace.', style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.35)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('PRÉFÉRENCES', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: AppColors.muted, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _setting(Icons.notifications_none_rounded, 'Notifications', _notifications),
          _setting(Icons.info_outline_rounded, 'À propos de I24H', _about),
          _setting(Icons.help_outline_rounded, 'Aide & assistance', _help),
          _setting(Icons.shield_outlined, 'Confidentialité', _privacy),
          _setting(Icons.logout_rounded, 'Se déconnecter', () => Navigator.pushReplacementNamed(context, '/login')),
        ],
      );

  Widget _setting(IconData icon, String title, VoidCallback action) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.line)),
          child: ListTile(
            onTap: action,
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: AppColors.blue, size: 21)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ),
        ),
      );

  Widget _miniPlayer() => InkWell(
        onTap: _openPlayer,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(.12), blurRadius: 14, offset: const Offset(0, 5))]),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.graphic_eq_rounded, color: AppColors.gold)),
            const SizedBox(width: 11),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('I24H · Direct', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              SizedBox(height: 3),
              Text('Lecteur en mode aperçu', style: TextStyle(color: Colors.white60, fontSize: 10)),
            ])),
            IconButton(onPressed: () => setState(() => playing = false), icon: const Icon(Icons.pause_rounded, color: Colors.white)),
            IconButton(onPressed: _openPlayer, icon: const Icon(Icons.open_in_full_rounded, color: Colors.white70, size: 20)),
          ]),
        ),
      );

  void _openPlayer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.navy,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 100, height: 100, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B4B83), Color(0xFF0D203B)]), borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 52)),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.live, borderRadius: BorderRadius.circular(8)), child: const Text('LIVE · I24H RADIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))),
            const SizedBox(height: 15),
            const Text('La radio en continu', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            const Text('Une présence, une parole, un moment.', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 22),
            _waveform(),
            const SizedBox(height: 22),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy, fixedSize: const Size(68, 68)),
              onPressed: () {
                setState(() => playing = !playing);
                Navigator.pop(sheetContext);
                if (playing) _snack('Aperçu visuel activé. Le flux audio réel doit encore être configuré.');
              },
              icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 35),
            ),
            const SizedBox(height: 18),
            const Text('Interface de lecteur prête · source audio à connecter', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        ),
      ),
    );
  }

  void _notifications() {
    setState(() => notifications = false);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Notifications', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
            SizedBox(height: 18),
            ListTile(leading: Icon(Icons.radio, color: AppColors.blue), title: Text('I24H est en direct'), subtitle: Text('Écoutez maintenant')),
            ListTile(leading: Icon(Icons.calendar_month, color: AppColors.blue), title: Text('Votre programme vous attend'), subtitle: Text('Consultez les rendez-vous du jour')),
            SizedBox(height: 8),
            Text('Les notifications push nécessitent encore une intégration serveur.', style: TextStyle(color: AppColors.muted, fontSize: 11)),
          ]),
        ),
      ),
    );
  }

  void _about() => _sheet('À propos de I24H', 'I24H — La voix qui vous accompagne. Une expérience radio, prière et communauté pensée pour rester simple, élégante et humaine. Version 1.0.0.');
  void _help() => _sheet('Aide & assistance', 'Besoin d’aide ? Consultez la FAQ, contactez notre équipe ou signalez un problème depuis votre espace.');
  void _privacy() => _sheet('Confidentialité', 'Les réglages et la conservation des données devront être reliés au service de compte I24H.');

  void _sheet(String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(body, style: const TextStyle(color: AppColors.muted, height: 1.5)),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))),
        ]),
      ),
    );
  }

  void _add() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déposer une intention'),
        content: TextField(controller: controller, maxLines: 5, decoration: const InputDecoration(hintText: 'Votre intention…')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _snack('Maquette : l’enregistrement serveur reste à connecter.');
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
