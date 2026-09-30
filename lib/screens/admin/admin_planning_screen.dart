import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AdminPlanningScreen extends StatefulWidget {
  const AdminPlanningScreen({super.key});
  @override
  State<AdminPlanningScreen> createState() => _AdminPlanningScreenState();
}

class _AdminPlanningScreenState extends State<AdminPlanningScreen> {
  final List<List<String>> items = [
    ['06:00 — 09:00','Edith A.','Réveil du Matin','À venir'],
    ['09:00 — 12:00','Chadrac T.','I24H Focus','Programmé'],
    ['12:00 — 14:00','Ruth K.','Pause Inspiration','Programmé'],
    ['14:00 — 18:00','Paul D.','Le Grand Direct','En direct'],
  ];

  void add() => showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => _PlanningForm(onSave:(row){setState(()=>items.add(row));Navigator.pop(context);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Émission ajoutée au planning')));},));

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Planning 24/7',style:TextStyle(fontSize:24,fontWeight:FontWeight.w800,color:AppColors.ink)),SizedBox(height:4),Text('Organisez les relais et évitez les interruptions.',style:TextStyle(color:AppColors.muted,fontSize:12))]),FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('Ajouter'))]),
    const SizedBox(height:18),
    ...items.map((r)=>Padding(padding:const EdgeInsets.only(bottom:10),child:I24HCard(child:Column(children:[Row(children:[Container(width:55,height:55,decoration:BoxDecoration(color:AppColors.navy.withOpacity(.07),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.schedule,color:AppColors.navy)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(r[2],style:const TextStyle(fontWeight:FontWeight.w800,color:AppColors.ink)),const SizedBox(height:4),Text('${r[0]} · ${r[1]}',style:const TextStyle(fontSize:12,color:AppColors.muted))])),StatusPill(label:r[3],color:r[3]=='En direct'?AppColors.success:AppColors.navy)]),const SizedBox(height:12),Row(mainAxisAlignment:MainAxisAlignment.end,children:[TextButton.icon(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Créneau modifié'))),icon:const Icon(Icons.edit_outlined,size:17),label:const Text('Modifier')),TextButton.icon(onPressed:()=>setState(()=>items.remove(r)),icon:const Icon(Icons.delete_outline,size:17,color:AppColors.danger),label:const Text('Supprimer',style:TextStyle(color:AppColors.danger)))])])))),
  ]);
}

class _PlanningForm extends StatefulWidget {
  final void Function(List<String>) onSave;
  const _PlanningForm({required this.onSave});
  @override State<_PlanningForm> createState()=>_PlanningFormState();
}
class _PlanningFormState extends State<_PlanningForm>{
  final emission=TextEditingController();final start=TextEditingController(text:'09:00');final end=TextEditingController(text:'10:00');String animator='Edith A.';
  @override void dispose(){emission.dispose();start.dispose();end.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Padding(padding:EdgeInsets.only(left:20,right:20,bottom:MediaQuery.viewInsetsOf(context).bottom+24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Ajouter au planning',style:TextStyle(fontSize:23,fontWeight:FontWeight.w800,color:AppColors.ink)),const SizedBox(height:18),TextField(controller:emission,decoration:const InputDecoration(labelText:'Nom de l’émission')),const SizedBox(height:12),DropdownButtonFormField<String>(value:animator,decoration:const InputDecoration(labelText:'Animateur'),items:['Edith A.','Chadrac T.','Ruth K.','Paul D.'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>animator=v!)),const SizedBox(height:12),Row(children:[Expanded(child:TextField(controller:start,decoration:const InputDecoration(labelText:'Début'))),const SizedBox(width:10),Expanded(child:TextField(controller:end,decoration:const InputDecoration(labelText:'Fin')))]),const SizedBox(height:18),SizedBox(width:double.infinity,height:50,child:FilledButton(onPressed:()=>widget.onSave([ '${start.text} — ${end.text}',animator,emission.text.isEmpty?'Nouvelle émission':emission.text,'À venir']),child:const Text('Publier dans le planning')))]));
}
