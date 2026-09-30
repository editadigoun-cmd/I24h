import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState()=>_LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>{
  bool signup=false, obscure=true;
  final name=TextEditingController(), email=TextEditingController(), pass=TextEditingController();
  void enter(){if(email.text.trim().isEmpty||pass.text.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Renseignez votre e-mail et votre mot de passe.')));return;}Navigator.pushReplacementNamed(context,'/mobile');}
  @override Widget build(BuildContext context)=>Scaffold(
    body:SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(24,28,24,32),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Container(width:54,height:54,decoration:BoxDecoration(color:AppColors.navy,borderRadius:BorderRadius.circular(17)),child:const Icon(Icons.graphic_eq_rounded,color:Colors.white,size:28)),
      const SizedBox(height:34),
      Text(signup?'Créer votre espace I24H':'Bienvenue chez I24H',style:Theme.of(context).textTheme.displaySmall),
      const SizedBox(height:10),
      Text(signup?'Une expérience personnelle, élégante et connectée.':'Retrouvez votre radio, vos programmes et votre communauté.',style:Theme.of(context).textTheme.bodyLarge?.copyWith(color:AppColors.muted)),
      const SizedBox(height:30),
      if(signup)...[TextField(controller:name,decoration:const InputDecoration(labelText:'Nom complet',prefixIcon:Icon(Icons.person_outline_rounded))),const SizedBox(height:14)],
      TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Adresse e-mail',prefixIcon:Icon(Icons.mail_outline_rounded))),
      const SizedBox(height:14),
      TextField(controller:pass,obscureText:obscure,decoration:InputDecoration(labelText:'Mot de passe',prefixIcon:const Icon(Icons.lock_outline_rounded),suffixIcon:IconButton(onPressed:()=>setState(()=>obscure=!obscure),icon:Icon(obscure?Icons.visibility_outlined:Icons.visibility_off_outlined)))),
      if(!signup)Align(alignment:Alignment.centerRight,child:TextButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Un lien de réinitialisation sera envoyé à votre e-mail.'))),child:const Text('Mot de passe oublié ?'))),
      const SizedBox(height:12),
      SizedBox(width:double.infinity,height:54,child:FilledButton(onPressed:enter,child:Text(signup?'Créer mon compte':'Se connecter'))),
      const SizedBox(height:18),
      Row(children:[const Expanded(child:Divider()),Padding(padding:const EdgeInsets.symmetric(horizontal:12),child:Text('OU',style:TextStyle(color:AppColors.muted,fontSize:12,fontWeight:FontWeight.w700))),const Expanded(child:Divider())]),
      const SizedBox(height:18),
      SizedBox(width:double.infinity,height:52,child:OutlinedButton.icon(onPressed:enter,icon:const Icon(Icons.person_outline_rounded),label:const Text('Continuer en mode découverte'))),
      const SizedBox(height:20),
      Center(child:TextButton(onPressed:()=>setState(()=>signup=!signup),child:Text(signup?'J’ai déjà un compte':'Créer un compte'))),
    ]))),
  );
}
