import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _slides = <_OnboardingSlide>[
    _OnboardingSlide(
      eyebrow: 'VOTRE RENDEZ-VOUS SPIRITUEL',
      title: 'La présence qui vous accompagne.',
      description:
          'Vivez les prières, les enseignements et les temps forts I24H, où que vous soyez.',
      icon: Icons.play_circle_fill_rounded,
      tag: 'PRIÈRE • PAROLE • ESPÉRANCE',
    ),
    _OnboardingSlide(
      eyebrow: 'EN DIRECT, ENSEMBLE',
      title: 'Plus proches, même à distance.',
      description:
          'Rejoignez le direct vidéo I24H et vivez les temps forts de la communauté, même à distance.',
      icon: Icons.groups_rounded,
      tag: 'DIRECT • COMMUNAUTÉ',
    ),
    _OnboardingSlide(
      eyebrow: 'VOTRE CONNEXION, VOTRE CHOIX',
      title: 'La vidéo ou simplement le son.',
      description:
          'Passez en mode écoute seule pour économiser vos données mobiles, sans quitter le direct.',
      icon: Icons.headphones_rounded,
      tag: 'MODE ÉCONOMIE DE DONNÉES',
    ),
  ];

  void _openApp() {
    Navigator.pushReplacementNamed(context, '/mobile');
  }

  void _openLogin() {
    Navigator.pushNamed(context, '/login');
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    } else {
      _openApp();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    return Scaffold(
      backgroundColor: const Color(0xFF07152E),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 22, 4),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.electric, AppColors.cyan],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x554C8DFF),
                          blurRadius: 22,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.navy,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I24H',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'LA FOI EN MOUVEMENT',
                        style: TextStyle(
                          color: Color(0xFF9DB4D7),
                          fontSize: 8,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _openApp,
                    child: const Text(
                      'Passer',
                      style: TextStyle(
                        color: Color(0xFFDCE7F9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) => _Scene(slide: _slides[index], index: index),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 4, 26, 26),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _index ? 30 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: index == _index
                              ? AppColors.cyan
                              : const Color(0xFF405372),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(19),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _index == _slides.length - 1
                                ? 'Entrer dans I24H'
                                : 'Continuer',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _openLogin,
                    child: const Text('J’ai déjà un compte — Se connecter'),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'UN ESPACE DE FOI. UNE COMMUNAUTÉ. UN MÊME ÉLAN.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7F96B9),
                      fontSize: 8,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final String tag;

  const _OnboardingSlide({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.tag,
  });
}

class _Scene extends StatelessWidget {
  final _OnboardingSlide slide;
  final int index;

  const _Scene({required this.slide, required this.index});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
      child: Column(
        children: [
          SizedBox(
            height: 330,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _OrbitPainter(variant: index)),
                ),
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2563FF).withOpacity(.36),
                        const Color(0xFF2563FF).withOpacity(.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 174,
                  height: 174,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF173E70), Color(0xFF0B1B36)],
                    ),
                    border: Border.all(color: const Color(0x6684CFFF), width: 1.2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x332A8CFF), blurRadius: 40, spreadRadius: 5),
                      BoxShadow(color: Color(0x22E8B65A), blurRadius: 55, spreadRadius: 8),
                    ],
                  ),
                  child: Icon(slide.icon, color: AppColors.cyan, size: 76),
                ),
                Positioned(
                  top: 43,
                  right: 20,
                  child: _FloatingChip(
                    icon: index == 0 ? Icons.auto_awesome_rounded : index == 1 ? Icons.favorite_rounded : Icons.bolt_rounded,
                    label: index == 0 ? 'INSPIRATION' : index == 1 ? 'ENSEMBLE' : 'ÉCONOME',
                    color: index == 1 ? const Color(0xFFFF8DAD) : AppColors.gold,
                  ),
                ),
                Positioned(
                  left: 3,
                  bottom: 46,
                  child: _FloatingChip(
                    icon: index == 0 ? Icons.menu_book_rounded : index == 1 ? Icons.chat_bubble_rounded : Icons.headphones_rounded,
                    label: index == 0 ? 'LA PAROLE' : index == 1 ? 'EN TEMPS RÉEL' : 'AUDIO SEUL',
                    color: AppColors.cyan,
                  ),
                ),
                Positioned(
                  bottom: 23,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132C50),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x334C8DFF)),
                    ),
                    child: Icon(
                      index == 0 ? Icons.waves_rounded : index == 1 ? Icons.bubble_chart_rounded : Icons.network_check_rounded,
                      color: AppColors.gold,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF122C4D),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0x334C8DFF)),
            ),
            child: Text(
              slide.eyebrow,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.cyan,
                fontSize: 9,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.12,
              letterSpacing: -1.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFB8C9E2),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            slide.tag,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF7893B9),
              fontSize: 9,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FloatingChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF102746),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(.45)),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 7)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                letterSpacing: .8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

class _OrbitPainter extends CustomPainter {
  final int variant;
  const _OrbitPainter({required this.variant});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      paint.color = const Color(0xFF5CAEFF).withOpacity(.22 - i * .035);
      canvas.drawCircle(center, 74 + i * 24, paint);
    }
    paint
      ..color = const Color(0x66E8B65A)
      ..strokeWidth = 1.4;
    final rect = Rect.fromCenter(
      center: center,
      width: 245,
      height: variant == 1 ? 205 : 230,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-.48 + variant * .24);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(rect, paint);
    canvas.restore();

    final starPaint = Paint()..style = PaintingStyle.fill;
    const points = [
      Offset(.13, .28), Offset(.82, .22), Offset(.75, .73),
      Offset(.22, .79), Offset(.9, .48), Offset(.09, .55),
      Offset(.62, .12), Offset(.42, .89),
    ];
    for (var i = 0; i < points.length; i++) {
      starPaint.color = i.isEven ? const Color(0xFF9FEAFF) : const Color(0xFFE8B65A);
      final p = Offset(size.width * points[i].dx, size.height * points[i].dy);
      canvas.drawCircle(p, i % 3 == 0 ? 2.2 : 1.3, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
