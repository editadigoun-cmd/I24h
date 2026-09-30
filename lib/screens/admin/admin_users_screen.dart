import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(18),children:[const Text('Utilisateurs',style:TextStyle(fontSize:24,fontWeight:FontWeight.w800,color:AppColors.ink)),const SizedBox(height:6),const Text('Suivez l’activité et les comptes de la communauté.',style:TextStyle(color:AppColors.muted)),const SizedBox(height:16),...['Aïcha K.','Jean M.','Mariam S.','David T.','Clara B.'].map((name)=>Padding(padding:const EdgeInsets.only(bottom:9),child:I24HCard(child:Row(children:[const CircleAvatar(backgroundColor:Color(0xFFE9EEF7),child:Icon(Icons.person_outline,color:AppColors.navy)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:const TextStyle(fontWeight:FontWeight.w800,color:AppColors.ink)),const SizedBox(height:3),const Text('Membre · Dernière activité récente',style:TextStyle(fontSize:12,color:AppColors.muted))])),const Icon(Icons.chevron_right_rounded,color:AppColors.muted)]))))]);
}
