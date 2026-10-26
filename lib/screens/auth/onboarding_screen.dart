import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int index = 0;

  final slides = const [
    (
      'assets/onboarding-priere.webp',
      'Votre radio.\nVotre moment.',
      'I24H vous accompagne en direct, avec des paroles, des émissions et des moments qui comptent.',
      Icons.graphic_eq_rounded,
    ),
    (
      'assets/onboarding-communaute.webp',
      'Une communauté\nqui vous ressemble.',
      'Retrouvez vos rendez-vous, partagez vos intentions et restez connecté à ceux qui vous inspirent.',
      Icons.groups_rounded,
    ),
    (
      'assets/onboarding-priere.webp',
      'Tout I24H,\nà portée de main.',
      'Le direct, les replays et votre espace personnel réunis dans une expérience simple et élégante.',
      Icons.play_circle_fill_rounded,
    ),
  ];

  void next() {
    if (index < slides.length - 1) {
      controller.nextPage(duration: const Duration(milliseconds: 360), curve: Curves.easeOutCubic);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navySoft]),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 23),
                    ),
                    const SizedBox(width: 10),
                    const Text('I24H', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: 1.2)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Passer', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: slides.length,
                    onPageChanged: (value) => setState(() => index = value),
                    itemBuilder: (_, i) {
                      final slide = slides[i];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 320,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.navy, Color(0xFF1B4779)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Stack(
                              children: [
                                Positioned(top: 18, right: 18, child: Icon(slide.$4, color: Colors.white.withOpacity(.18), size: 70)),
                                Positioned(left: 22, right: 22, bottom: 18, child: Container(height: 1, color: Colors.white.withOpacity(.15))),
                                Padding(
                                  padding: const EdgeInsets.all(17),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Image.asset(slide.$1, fit: BoxFit.contain, width: double.infinity),
                                  ),
                                ),
                                Positioned(
                                  left: 18,
                                  top: 18,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: AppColors.live, borderRadius: BorderRadius.circular(8)),
                                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.circle, color: Colors.white, size: 6),
                                      SizedBox(width: 6),
                                      Text('VOTRE UNIVERS I24H', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .8)),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 34),
                          Text(slide.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 31, height: 1.08, letterSpacing: -1, fontWeight: FontWeight.w900, color: AppColors.navy)),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(slide.$3, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 1.55, color: AppColors.muted)),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(slides.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == index ? 27 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == index ? AppColors.blue : const Color(0xFFD9E0EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed: next,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(index == slides.length - 1 ? 'Entrer dans I24H' : 'Continuer'),
                      const SizedBox(width: 9),
                      const Icon(Icons.arrow_forward_rounded, size: 19),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
