import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import 'admin_planning_screen.dart';

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(22), children: [
    const Text('Bonjour, administrateur', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: AppColors.ink)),
    const SizedBox(height: 6),
    const Text('Voici l’état de la plateforme I24H.', style: TextStyle(color: AppColors.muted)),
    const SizedBox(height: 20),
    GridView.count(crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.25, children: const [
      StatCard(value:'12.4K',label:'Auditeurs actifs',icon:Icons.people_alt_outlined), StatCard(value:'24/7',label:'Diffusion',icon:Icons.graphic_eq), StatCard(value:'36',label:'Émissions',icon:Icons.play_circle_outline), StatCard(value:'98%',label:'Disponibilité',icon:Icons.check_circle_outline),
    ]),
    const SizedBox(height: 22),
    const SectionTitle(title:'Direct maintenant'),
    I24HCard(child: Row(children: [Container(width:54,height:54,decoration:BoxDecoration(color:AppColors.navy,borderRadius:BorderRadius.circular(16)),child:const Icon(Icons.graphic_eq,color:Colors.white)),const SizedBox(width:14),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('I24H Radio',style:TextStyle(fontWeight:FontWeight.w800,color:AppColors.ink)),SizedBox(height:4),Text('Le Grand Direct · 14:00 — 18:00',style:TextStyle(color:AppColors.muted,fontSize:12))])),const StatusPill(label:'ON AIR')])) ,
    const SizedBox(height: 22),
    const SectionTitle(title:'Actions rapides'),
    Wrap(spacing:9,runSpacing:9,children:[FilledButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const AdminPlanningScreen())),icon:const Icon(Icons.add),label:const Text('Ajouter au planning')),OutlinedButton.icon(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Nouvelle émission'))),icon:const Icon(Icons.play_circle_outline),label:const Text('Nouvelle émission'))]),
    const SizedBox(height: 22),
    const SectionTitle(title:'Activité récente'),
    ...['Planning mis à jour pour 18:00','Nouvel animateur ajouté','3 dons reçus aujourd’hui','Émission « I24H Focus » publiée'].map((x)=>Padding(padding:const EdgeInsets.only(bottom:9),child:I24HCard(child:Row(children:[const Icon(Icons.check_circle_outline,color:AppColors.success),const SizedBox(width:12),Expanded(child:Text(x,style:const TextStyle(fontWeight:FontWeight.w600,color:AppColors.ink))),const Icon(Icons.chevron_right_rounded,color:AppColors.muted)]))))
  ]);
}
