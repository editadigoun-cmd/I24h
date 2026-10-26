import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool signup = false, obscure = true, loading = false;
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> enter() async {
    if (email.text.trim().isEmpty || pass.text.isEmpty) {
      _message('Renseignez votre e-mail et votre mot de passe.');
      return;
    }
    if (signup && name.text.trim().isEmpty) {
      _message('Renseignez votre nom complet.');
      return;
    }

    setState(() => loading = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (signup) {
        final response = await auth.signUp(
          email: email.text.trim(),
          password: pass.text,
          data: {'full_name': name.text.trim()},
        );
        if (!mounted) return;
        if (response.session == null) {
          _message('Compte créé. Vérifiez votre e-mail pour confirmer votre inscription.');
          return;
        }
      } else {
        await auth.signInWithPassword(
          email: email.text.trim(),
          password: pass.text,
        );
      }
      await _openCorrectSpace();
    } on AuthException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) _message('Connexion impossible. Vérifiez Internet puis réessayez.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openCorrectSpace() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    var route = '/mobile';
    if (user != null) {
      try {
        final profile = await client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();
        switch (profile?['role'] as String?) {
          case 'admin':
            route = '/admin';
          case 'animateur':
            route = '/animateur';
          default:
            route = '/mobile';
        }
      } catch (_) {
        // A missing profile must never grant elevated access.
        route = '/mobile';
      }
    }
    if (mounted) Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _resetPassword() async {
    if (email.text.trim().isEmpty) {
      _message('Saisissez votre e-mail avant de demander un lien.');
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email.text.trim());
      if (mounted) _message('Si cette adresse existe, un lien de réinitialisation sera envoyé.');
    } on AuthException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) _message('Impossible d’envoyer le lien pour le moment.');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(17)),
              child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 34),
            Text(signup ? 'Créer votre espace I24H' : 'Bienvenue chez I24H',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 10),
            Text(
              signup ? 'Une expérience personnelle, élégante et connectée.' : 'Retrouvez votre radio, vos programmes et votre communauté.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 30),
            if (signup) ...[
              TextField(controller: name, textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nom complet', prefixIcon: Icon(Icons.person_outline_rounded))),
              const SizedBox(height: 14),
            ],
            TextField(controller: email, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Adresse e-mail', prefixIcon: Icon(Icons.mail_outline_rounded))),
            const SizedBox(height: 14),
            TextField(
              controller: pass,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
            ),
            if (!signup)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: loading ? null : _resetPassword, child: const Text('Mot de passe oublié ?')),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: loading ? null : enter,
                child: loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(signup ? 'Créer mon compte' : 'Se connecter'),
              ),
            ),
            const SizedBox(height: 18),
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('OU', style: TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: loading ? null : () => Navigator.pushReplacementNamed(context, '/mobile'),
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('Continuer en mode découverte'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: loading ? null : () => setState(() => signup = !signup),
                child: Text(signup ? 'J’ai déjà un compte' : 'Créer un compte'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
