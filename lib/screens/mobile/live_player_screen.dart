import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LivePlayerScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isLive;

  const LivePlayerScreen({
    super.key,
    this.title = 'I24H — La radio en continu',
    this.subtitle = 'La voix qui vous accompagne',
    this.isLive = true,
  });

  @override
  State<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends State<LivePlayerScreen> {
  bool playing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09182D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF09182D), Color(0xFF122F55), Color(0xFF1B4578)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                    ),
                    const Expanded(
                      child: Text('LECTEUR I24H', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD4DEEC), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w800)),
                    ),
                    IconButton(
                      tooltip: 'Partager',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le partage sera activé dans une prochaine étape.'))),
                      icon: const Icon(Icons.ios_share_rounded, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              Container(
                width: 224,
                height: 224,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withOpacity(0.35), width: 1),
                  boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 36, spreadRadius: 2)],
                ),
                child: Center(
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF244F83), Color(0xFF0D2341)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 58),
                        SizedBox(height: 12),
                        Text('I24H', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3)),
                        SizedBox(height: 4),
                        Text('RADIO • PRIÈRE • COMMUNAUTÉ', style: TextStyle(color: Color(0xFFD4DEEC), fontSize: 7, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 42),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(color: widget.isLive ? const Color(0x33FF6B6B) : const Color(0x33C89B3C), borderRadius: BorderRadius.circular(30)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: widget.isLive ? const Color(0xFFFF7777) : AppColors.gold, shape: BoxShape.circle)),
                        const SizedBox(width: 7),
                        Text(widget.isLive ? 'EN DIRECT' : 'REPLAY', style: const TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w900)),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    Text(widget.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, height: 1.2, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
                    const SizedBox(height: 8),
                    Text(widget.subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFBAC9DC), fontSize: 14)),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(25, (index) {
                  final heights = [10, 18, 28, 16, 35, 22, 42, 25, 15, 31, 45, 20, 34, 13, 26, 39, 17, 29, 44, 20, 32, 14, 25, 37, 18];
                  return Container(
                    width: 4,
                    height: heights[index].toDouble(),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(color: index % 4 == 0 ? AppColors.gold : const Color(0xFF89A8D2), borderRadius: BorderRadius.circular(8)),
                  );
                }),
              ),
              const SizedBox(height: 34),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le minuteur sera ajouté prochainement.'))), icon: const Icon(Icons.bedtime_outlined, color: Colors.white70, size: 25)),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x44C89B3C), blurRadius: 20, spreadRadius: 2)]),
                      child: IconButton(
                        onPressed: () => setState(() => playing = !playing),
                        icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.navy, size: 40),
                      ),
                    ),
                    IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le réglage audio sera disponible avec le flux réel.'))), icon: const Icon(Icons.tune_rounded, color: Colors.white70, size: 25)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text('Le flux audio sera connecté à cette interface lors de l’intégration technique.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9FB2CB), fontSize: 11, height: 1.45)),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
