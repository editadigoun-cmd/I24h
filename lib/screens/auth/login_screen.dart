import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/i24h_icon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool create = false;
  bool obscure = true;

  void openRole(String route) => Navigator.pushReplacementNamed(context, route);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 18))),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const I24HLogo(size: 54),
        const SizedBox(height: 28),
        Text(create ? 'Créer votre compte' : 'Bienvenue sur I24H', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 8),
        Text(create ? 'Rejoignez une communauté qui reste connectée.' : 'Connectez-vous pour retrouver votre expérience personnalisée.', style: const TextStyle(color: AppColors.muted, height: 1.5)),
        const SizedBox(height: 30),
        if (create) ...[
          const TextField(decoration: InputDecoration(labelText: 'Nom complet', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 14),
        ],
        const TextField(keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'Adresse e-mail', prefixIcon: Icon(Icons.mail_outline))),
        const SizedBox(height: 14),
        TextField(obscureText: obscure, decoration: InputDecoration(labelText: 'Mot de passe', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
        const SizedBox(height: 22),
        PrimaryButton(label: create ? 'Créer mon compte' : 'Se connecter', onPressed: () => openRole('/mobile'), icon: create ? Icons.person_add_alt_1 : Icons.login),
        const SizedBox(height: 12),
        Center(child: TextButton(onPressed: () => setState(() => create = !create), child: Text(create ? 'J’ai déjà un compte' : 'Créer un compte'))),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 18),
        const Text('Accès de démonstration', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () => openRole('/admin'), icon: const Icon(Icons.dashboard_outlined), label: const Text('Ouvrir l’espace administrateur'), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () => openRole('/animateur'), icon: const Icon(Icons.mic_none_rounded), label: const Text('Ouvrir le studio animateur'), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
      ]),
    ),
  );
}
