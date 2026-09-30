import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AdminAnimateursScreen extends StatelessWidget {
  const AdminAnimateursScreen({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(18),children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Animateurs',style:TextStyle(fontSize:24,fontWeight:FontWeight.w800,color:AppColors.ink)),FilledButton.icon(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Ajouter un animateur'))),icon:const Icon(Icons.add),label:const Text('Ajouter'))]),const SizedBox(height:16),...['Edith A.','Chadrac T.','Ruth K.','Paul D.'].map((name)=>Padding(padding:const EdgeInsets.only(bottom:10),child:I24HCard(child:Row(children:[const CircleAvatar(backgroundColor:AppColors.navy,child:Icon(Icons.person,color:Colors.white)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:const TextStyle(fontWeight:FontWeight.w800,color:AppColors.ink)),const SizedBox(height:3),const Text('Animateur · Actif',style:TextStyle(fontSize:12,color:AppColors.muted))])),const StatusPill(label:'Actif'),IconButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Profil de $name'))),icon:const Icon(Icons.chevron_right_rounded))]))))]);
}
