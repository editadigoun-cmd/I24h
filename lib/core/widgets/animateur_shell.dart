import 'package:flutter/material.dart';
import '../../screens/animateur/animateur_dashboard_screen.dart';
import '../../screens/animateur/animateur_live_screen.dart';
import '../../screens/animateur/animateur_planning_screen.dart';
import '../../screens/animateur/animateur_replays_screen.dart';
import '../../screens/animateur/animateur_profile_screen.dart';
import '../theme/app_theme.dart';

class AnimateurShell extends StatefulWidget {
  const AnimateurShell({super.key});
  @override State<AnimateurShell> createState()=>_AnimateurShellState();
}
class _AnimateurShellState extends State<AnimateurShell>{int index=0;final pages=const[AnimateurDashboardContent(),AnimateurLiveScreen(),AnimateurPlanningScreen(),AnimateurReplaysScreen(),AnimateurProfileScreen()];@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Studio I24H',style:TextStyle(fontWeight:FontWeight.w800)),actions:[IconButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Notifications studio'))),icon:const Icon(Icons.notifications_none_rounded))]),body:Row(children:[if(MediaQuery.sizeOf(context).width>=850)NavigationRail(selectedIndex:index,onDestinationSelected:(v)=>setState(()=>index=v),labelType:NavigationRailLabelType.all,destinations:const[NavigationRailDestination(icon:Icon(Icons.dashboard_outlined),label:Text('Accueil')),NavigationRailDestination(icon:Icon(Icons.mic_none),label:Text('Direct')),NavigationRailDestination(icon:Icon(Icons.calendar_month_outlined),label:Text('Planning')),NavigationRailDestination(icon:Icon(Icons.replay_outlined),label:Text('Replays')),NavigationRailDestination(icon:Icon(Icons.person_outline),label:Text('Profil'))]),Expanded(child:pages[index])]),bottomNavigationBar:MediaQuery.sizeOf(context).width<850?NavigationBar(selectedIndex:index,onDestinationSelected:(v)=>setState(()=>index=v),indicatorColor:AppColors.navy.withOpacity(.1),destinations:const[NavigationDestination(icon:Icon(Icons.dashboard_outlined),label:'Accueil'),NavigationDestination(icon:Icon(Icons.mic_none),label:'Direct'),NavigationDestination(icon:Icon(Icons.calendar_month_outlined),label:'Planning'),NavigationDestination(icon:Icon(Icons.replay_outlined),label:'Replays'),NavigationDestination(icon:Icon(Icons.person_outline),label:'Profil')]):null);}
