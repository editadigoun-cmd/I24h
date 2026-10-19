import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/i24h_config.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool signup = false;
  bool obscure = true;
  bool loading = false;

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

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (loading) return;
    if (!I24HConfig.backendReady) {
      _message(
        'Le service de comptes I24H n’est pas encore configuré. '
        'La connexion est bloquée jusqu’à la mise en place du backend.',
      );
      return;
    }

    final emailValue = email.text.trim();
    if (emailValue.isEmpty || pass.text.isEmpty) {
      _message('Renseignez votre adresse e-mail et votre mot de passe.');
      return;
    }
    if (signup && name.text.trim().isEmpty) {
      _message('Renseignez votre nom complet.');
      return;
    }
    if (signup && pass.text.length < 8) {
      _message('Choisissez un mot de passe d’au moins 8 caractères.');
      return;
    }

    setState(() => loading = true);
    try {
      final client = Supabase.instance.client;
      if (signup) {
        final response = await client.auth.signUp(
          email: emailValue,
          password: pass.text,
          data: {'full_name': name.text.trim()},
        );
        if (!mounted) return;
        if (response.session != null) {
          Navigator.pushReplacementNamed(context, '/mobile');
        } else {
          _message(
            'Compte créé. Consultez votre e-mail pour confirmer '
            'votre adresse avant de vous connecter.',
          );
          setState(() => signup = false);
        }
      } else {
        await client.auth.signInWithPassword(
          email: emailValue,
          password: pass.text,
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/mobile');
      }
    } on AuthException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Une erreur est survenue. Vérifiez votre connexion et réessayez.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!I24HConfig.backendReady) {
      _message('Le service de comptes I24H n’est pas encore configuré.');
      return;
    }
    final emailValue = email.text.trim();
    if (emailValue.isEmpty) {
      _message('Saisissez votre e-mail pour recevoir le lien de réinitialisation.');
      return;
    }

    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(emailValue);
      _message('Si cette adresse est enregistrée, un e-mail de réinitialisation sera envoyé.');
    } on AuthException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Impossible d’envoyer le lien pour le moment. Réessayez.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
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
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 34),
                Text(
                  signup ? 'Créer votre espace I24H' : 'Bienvenue chez I24H',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 10),
                Text(
                  signup
                      ? 'Créez votre compte pour rejoindre la communauté.'
                      : 'Connectez-vous pour retrouver vos programmes et votre communauté.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 20),
                if (!I24HConfig.backendReady)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.sky,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.navy),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Le backend doit encore être configuré. '
                            'Les comptes ne seront pas acceptés tant que cette étape ne sera pas terminée.',
                            style: TextStyle(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 22),
                if (signup) ...[
                  TextField(
                    controller: name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pass,
                  obscureText: obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                if (!signup)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: loading ? null : _resetPassword,
                      child: const Text('Mot de passe oublié ?'),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(signup ? 'Créer mon compte' : 'Se connecter'),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: loading ? null : () => setState(() => signup = !signup),
                    child: Text(
                      signup ? 'J’ai déjà un compte' : 'Créer un compte',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
