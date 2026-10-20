import 'package:flutter/material.dart';
import '../../core/config/i24h_config.dart';
import '../../core/theme/app_theme.dart';
import 'live_player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LivePlayerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.navy, Color(0xFF234D82)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('I24H', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: 1.1)),
                          SizedBox(height: 2),
                          Text('La voix qui vous accompagne', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Les notifications seront disponibles prochainement.')),
                      ),
                      style: IconButton.styleFrom(backgroundColor: Colors.white),
                      icon: const Icon(Icons.notifications_none_rounded, color: AppColors.navy),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text('Un moment de paix,', style: TextStyle(fontSize: 28, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -0.9, color: AppColors.ink)),
                const Text('où que vous soyez.', style: TextStyle(fontSize: 28, height: 1.15, fontWeight: FontWeight.w900, letterSpacing: -0.9, color: AppColors.blue)),
                const SizedBox(height: 10),
                const Text('Retrouvez la parole, la prière et la communauté I24H tout au long de la journée.', style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted)),
                const SizedBox(height: 24),
                _LiveHero(
                  onListen: () => _openPlayer(context),
                  isConfigured: true,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(child: Text('À découvrir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.ink))),
                    TextButton(onPressed: () {}, child: const Text('Explorer')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _QuickAction(icon: Icons.calendar_month_rounded, title: 'Programme', subtitle: 'Les rendez-vous', tint: const Color(0xFFEAF2FF), color: AppColors.blue, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouvrez Programme depuis le menu en bas.'))))),
                    const SizedBox(width: 12),
                    Expanded(child: _QuickAction(icon: Icons.favorite_rounded, title: 'Intentions', subtitle: 'Un temps pour prier', tint: const Color(0xFFFFF2E8), color: const Color(0xFFB96D35), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouvrez Intentions depuis le menu en bas.'))))),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(child: Text('Prochain rendez-vous', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.ink))),
                    const Text('Aujourd’hui', style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 62,
                        decoration: BoxDecoration(color: const Color(0xFFFFF7E6), borderRadius: BorderRadius.circular(16)),
                        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('18:00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.navy)),
                          SizedBox(height: 3),
                          Text('PRIÈRE', style: TextStyle(fontSize: 8, letterSpacing: 0.8, fontWeight: FontWeight.w800, color: AppColors.gold)),
                        ]),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Temps de prière', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ink)),
                        SizedBox(height: 5),
                        Text('Un rendez-vous pour se recentrer et partager', style: TextStyle(fontSize: 12, height: 1.35, color: AppColors.muted)),
                      ])),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('La communauté I24H', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.navy)),
                        SizedBox(height: 5),
                        Text('Restez connecté à vos rendez-vous spirituels.', style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.muted)),
                      ])),
                      const SizedBox(width: 10),
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.diversity_3_rounded, color: AppColors.blue, size: 25)),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveHero extends StatelessWidget {
  final VoidCallback onListen;
  final bool isConfigured;
  const _LiveHero({required this.onListen, required this.isConfigured});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF091A31), Color(0xFF173E72), Color(0xFF24518A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x1F0B1F3A), blurRadius: 24, offset: Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            const Text('ESPACE DIRECT', style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(30)), child: const Text('24H / 24', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 22),
          Text(isConfigured ? 'Le direct vidéo I24H' : 'Le direct vidéo I24H', style: const TextStyle(color: Colors.white, fontSize: 23, height: 1.15, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
          const SizedBox(height: 8),
          const Text('Ouvrez le lecteur pour rejoindre la diffusion si elle est en cours.', style: TextStyle(color: Color(0xFFD4DEEC), fontSize: 13)),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onListen,
                style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy, minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 25),
                label: const Text('Regarder le direct', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)), child: const Icon(Icons.live_tv_rounded, color: AppColors.gold, size: 25)),
          ]),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.tint, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 23)),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.3)),
          ]),
        ),
      ),
    );
  }
}
