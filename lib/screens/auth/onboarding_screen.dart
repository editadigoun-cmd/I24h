import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/i24h_icon.dart';
import '../../core/widgets/app_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int index = 0;

  final items = const [
    ('assets/onboarding-priere.webp', 'Une radio qui vous accompagne', 'Écoutez I24H en direct et retrouvez vos programmes, où que vous soyez.'),
    ('assets/onboarding-communaute.webp', 'Une communauté vivante', 'Partagez vos intentions, échangez et restez connecté à la communauté I24H.'),
  ];

  void next() {
    if (index < items.length - 1) {
      controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const I24HLogo(), TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Passer'))]),
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: items.length,
              onPageChanged: (v) => setState(() => index = v),
              itemBuilder: (_, i) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.asset(items[i].$1, height: 280, width: double.infinity, fit: BoxFit.contain)),
                const SizedBox(height: 30),
                Text(items[i].$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.12)),
                const SizedBox(height: 14),
                Text(items[i].$3, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppColors.muted, height: 1.55)),
              ]),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(items.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 4), width: i == index ? 24 : 7, height: 7, decoration: BoxDecoration(color: i == index ? AppColors.navy : AppColors.line, borderRadius: BorderRadius.circular(20))))),
          const SizedBox(height: 20),
          PrimaryButton(label: index == items.length - 1 ? 'Commencer' : 'Continuer', onPressed: next, icon: Icons.arrow_forward_rounded),
        ]),
      ),
    ),
  );
}
