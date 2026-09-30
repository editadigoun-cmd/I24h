import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final c=PageController(); int i=0;
  final slides=const [
    ('assets/onboarding-priere.webp','Votre radio. Votre moment.','I24H vous accompagne en direct, dans la prière, la musique et les paroles qui comptent.'),
    ('assets/onboarding-communaute.webp','Une communauté qui vous ressemble','Déposez vos intentions, retrouvez vos émissions et vivez une expérience pensée pour vous.'),
    ('assets/onboarding-priere.webp','Tout I24H, dans une seule application','Programme, replay, notifications, profil et soutien : votre univers I24H, avec élégance et simplicité.'),
  ];
  void next(){if(i<slides.length-1)c.nextPage(duration:const Duration(milliseconds:350),curve:Curves.easeOutCubic);else Navigator.pushReplacementNamed(context,'/login');}
  @override Widget build(BuildContext context)=>Scaffold(
    body: SafeArea(child: Padding(padding:const EdgeInsets.fromLTRB(22,18,22,22),child:Column(children:[
      Row(children:[const Text('I24H',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900,color:AppColors.navy,letterSpacing:1.5)),const Spacer(),TextButton(onPressed:()=>Navigator.pushReplacementNamed(context,'/login'),child:const Text('Passer'))]),
      Expanded(child:PageView.builder(controller:c,itemCount:slides.length,onPageChanged:(v)=>setState(()=>i=v),itemBuilder:(_,n){
        final s=slides[n]; return Column(mainAxisAlignment:MainAxisAlignment.center,children:[
          Container(height:330,width:double.infinity,padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.sky,borderRadius:BorderRadius.circular(34)),child:Image.asset(s.$1,fit:BoxFit.contain)),
          const SizedBox(height:36),
          Text(s.$2,textAlign:TextAlign.center,style:Theme.of(context).textTheme.displaySmall),
          const SizedBox(height:14),
          Text(s.$3,textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodyLarge?.copyWith(color:AppColors.muted)),
        ]);
      })),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(slides.length,(n)=>AnimatedContainer(duration:const Duration(milliseconds:250),margin:const EdgeInsets.all(4),width:n==i?28:7,height:7,decoration:BoxDecoration(color:n==i?AppColors.gold:AppColors.line,borderRadius:BorderRadius.circular(8))))),
      const SizedBox(height:20),
      SizedBox(width:double.infinity,height:54,child:FilledButton(onPressed:next,child:Text(i==slides.length-1?'Découvrir I24H':'Continuer'))),
    ]))),
  );
}
