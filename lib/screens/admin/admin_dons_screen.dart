import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AdminDonsScreen extends StatelessWidget {
  const AdminDonsScreen({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(18),children:[const Text('Dons',style:TextStyle(fontSize:24,fontWeight:FontWeight.w800,color:AppColors.ink)),const SizedBox(height:16),GridView.count(crossAxisCount:MediaQuery.sizeOf(context).width>700?3:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.25,children:const[StatCard(value:'1.24M',label:'Total FCFA',icon:Icons.payments_outlined),StatCard(value:'186',label:'Donateurs',icon:Icons.people_outline),StatCard(value:'98%',label:'Confirmés',icon:Icons.check_circle_outline)]),const SizedBox(height:20),...['25 000 FCFA · Aïcha K.','10 000 FCFA · Jean M.','50 000 FCFA · David T.','15 000 FCFA · Clara B.'].map((x)=>Padding(padding:const EdgeInsets.only(bottom:9),child:I24HCard(child:Row(children:[const Icon(Icons.favorite_rounded,color:AppColors.gold),const SizedBox(width:12),Expanded(child:Text(x,style:const TextStyle(fontWeight:FontWeight.w700,color:AppColors.ink))),const StatusPill(label:'Confirmé')]))))]);
}
