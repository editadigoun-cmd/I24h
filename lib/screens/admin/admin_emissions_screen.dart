import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AdminEmissionsScreen extends StatelessWidget {
  const AdminEmissionsScreen({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(18),children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Émissions & replays',style:TextStyle(fontSize:24,fontWeight:FontWeight.w800,color:AppColors.ink)),FilledButton.icon(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Créer une émission'))),icon:const Icon(Icons.add),label:const Text('Créer'))]),const SizedBox(height:16),...['Réveil du Matin','I24H Focus','Le Grand Direct','Paroles & enseignements'].map((x)=>Padding(padding:const EdgeInsets.only(bottom:10),child:I24HCard(child:Row(children:[Container(width:48,height:48,decoration:BoxDecoration(color:AppColors.navy.withOpacity(.08),borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.play_circle_outline,color:AppColors.navy)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(x,style:const TextStyle(fontWeight:FontWeight.w800,color:AppColors.ink)),const SizedBox(height:3),const Text('Publié · Replay disponible',style:TextStyle(fontSize:12,color:AppColors.muted))])),IconButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Modifier $x'))),icon:const Icon(Icons.edit_outlined))])) )]);
}
