import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/i24h_config.dart';
import '../../core/services/i24h_backend.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool signup = false;
  bool obscure = true;
  bool obscureConfirm = true;
  bool loading = false;
  bool checkingBackend = false;
  bool acceptedTerms = false;
  bool? backendConnected;

  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirmPass = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (I24HConfig.backendReady) _verifyBackend();
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    pass.dispose();
    confirmPass.dispose();
    super.dispose();
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
  }

  Future<void> _verifyBackend() async {
    if (checkingBackend) return;
    setState(() {
      checkingBackend = true;
      backendConnected = null;
    });
    try {
      await I24HBackend.checkConnection();
      if (mounted) setState(() => backendConnected = true);
    } catch (error) {
      if (mounted) {
        setState(() => backendConnected = false);
        I24HConfig.backendError = error.toString();
      }
    } finally {
      if (mounted) setState(() => checkingBackend = false);
    }
  }

  Future<void> _submit() async {
    if (loading) return;
    if (!I24HConfig.backendReady) {
      _message(
        I24HConfig.backendError ??
            'Le service de comptes ne s’est pas initialisé. Vérifiez la version de l’application et la connexion Internet.',
      );
      await _verifyBackend();
      return;
    }

    final emailValue = email.text.trim();
    if (emailValue.isEmpty || !emailValue.contains('@')) {
      _message('Saisissez une adresse e-mail valide.');
      return;
    }
    if (pass.text.isEmpty) {
      _message('Saisissez votre mot de passe.');
      return;
    }
    if (signup && name.text.trim().length < 2) {
      _message('Renseignez votre nom complet.');
      return;
    }
    if (signup && pass.text.length < 8) {
      _message('Choisissez un mot de passe d’au moins 8 caractères.');
      return;
    }
    if (signup && pass.text != confirmPass.text) {
      _message('Les deux mots de passe ne correspondent pas.');
      return;
    }
    if (signup && !acceptedTerms) {
      _message('Veuillez accepter les conditions et la politique de confidentialité.');
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
          Navigator.pushNamedAndRemoveUntil(context, '/mobile', (_) => false);
        } else {
          _message(
            'Votre compte est créé. Ouvrez l’e-mail de confirmation envoyé par I24H, puis revenez vous connecter.',
          );
          setState(() => signup = false);
        }
      } else {
        await client.auth.signInWithPassword(
          email: emailValue,
          password: pass.text,
        );
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/mobile', (_) => false);
        }
      }
    } on AuthException catch (error) {
      _message(_friendlyAuthError(error.message));
    } catch (error) {
      _message('Connexion impossible. Vérifiez Internet et réessayez.');
      debugPrint('I24H auth error: $error');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _friendlyAuthError(String message) {
    final value = message.toLowerCase();
    if (value.contains('invalid login credentials')) {
      return 'E-mail ou mot de passe incorrect.';
    }
    if (value.contains('email not confirmed')) {
      return 'Confirmez votre adresse e-mail avant de vous connecter.';
    }
    if (value.contains('user already registered')) {
      return 'Cette adresse possède déjà un compte. Connectez-vous plutôt.';
    }
    if (value.contains('password should be at least')) {
      return 'Votre mot de passe doit contenir au moins 8 caractères.';
    }
    return message;
  }

  Future<void> _resetPassword() async {
    if (!I24HConfig.backendReady) {
      _message('Le service de comptes est indisponible pour le moment.');
      return;
    }
    final emailValue = email.text.trim();
    if (emailValue.isEmpty || !emailValue.contains('@')) {
      _message('Saisissez votre adresse e-mail dans le champ prévu.');
      return;
    }
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(emailValue);
      _message('Si cette adresse est enregistrée, un lien de réinitialisation sera envoyé.');
    } on AuthException catch (error) {
      _message(_friendlyAuthError(error.message));
    } catch (_) {
      _message('Impossible d’envoyer le lien pour le moment. Réessayez.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF07152E), Color(0xFF12386A), Color(0xFF1C4F91)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -70,
                  top: -85,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x225FE3FF), width: 28),
                    ),
                  ),
                ),
                Positioned(
                  right: 35,
                  top: 68,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.cyan.withOpacity(.32), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.electric, AppColors.cyan],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.graphic_eq_rounded, color: AppColors.navy, size: 26),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('I24H', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                Text('LA FOI EN MOUVEMENT', style: TextStyle(color: Color(0xFF9DB8DC), fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          signup ? 'Rejoignez la communauté.' : 'Heureux de vous retrouver.',
                          style: const TextStyle(color: Colors.white, fontSize: 26, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -.7),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          signup
                              ? 'Créez votre espace personnel et vivez chaque rendez-vous avec I24H.'
                              : 'Reconnectez-vous à vos prières, vos programmes et votre communauté.',
                          style: const TextStyle(color: Color(0xFFD1DFF1), fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 34),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 236, 18, 30),
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE8EDF6)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x18091B38), blurRadius: 35, offset: Offset(0, 16)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            signup ? 'Créer mon compte' : 'Connexion',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.7, color: AppColors.ink),
                          ),
                        ),
                        _SecureBadge(),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      signup
                          ? 'Quelques informations pour commencer.'
                          : 'Accédez à votre espace I24H en toute sécurité.',
                      style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.45),
                    ),
                    const SizedBox(height: 20),
                    _BackendStatus(
                      ready: I24HConfig.backendReady,
                      connected: backendConnected,
                      checking: checkingBackend,
                      onRetry: _verifyBackend,
                    ),
                    if (signup) ...[
                      const SizedBox(height: 17),
                      _FieldLabel(label: 'NOM COMPLET'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Ex. Marie Adjoua',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                    ],
                    const SizedBox(height: 17),
                    _FieldLabel(label: 'ADRESSE E-MAIL'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'vous@exemple.com',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                    const SizedBox(height: 17),
                    _FieldLabel(label: 'MOT DE PASSE'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: pass,
                      obscureText: obscure,
                      textInputAction: signup ? TextInputAction.next : TextInputAction.done,
                      onSubmitted: (_) {
                        if (!signup) _submit();
                      },
                      decoration: InputDecoration(
                        hintText: '8 caractères minimum',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                    ),
                    if (signup) ...[
                      const SizedBox(height: 17),
                      _FieldLabel(label: 'CONFIRMER LE MOT DE PASSE'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmPass,
                        obscureText: obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: 'Retapez votre mot de passe',
                          prefixIcon: const Icon(Icons.verified_user_outlined),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                            icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        value: acceptedTerms,
                        onChanged: (value) => setState(() => acceptedTerms = value ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        activeColor: AppColors.blue,
                        title: const Text(
                          'J’accepte les conditions d’utilisation et la politique de confidentialité.',
                          style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.4),
                        ),
                      ),
                    ] else
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
                      height: 56,
                      child: FilledButton(
                        onPressed: loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                        ),
                        child: loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(signup ? 'Créer mon espace' : 'Se connecter', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.line)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(signup ? 'DÉJÀ MEMBRE ?' : 'NOUVEAU SUR I24H ?', style: const TextStyle(color: AppColors.muted, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
                        ),
                        const Expanded(child: Divider(color: AppColors.line)),
                      ],
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: loading
                            ? null
                            : () => setState(() {
                                  signup = !signup;
                                  acceptedTerms = false;
                                }),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(color: AppColors.line),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          signup ? 'J’ai déjà un compte' : 'Créer un compte gratuitement',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.success, size: 15),
                        SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Vos informations sont traitées de manière sécurisée.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          color: Color(0xFF68748A),
          fontSize: 9,
          letterSpacing: 1.25,
          fontWeight: FontWeight.w900,
        ),
      );
}

class _SecureBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF8F1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user_rounded, size: 13, color: AppColors.success),
            SizedBox(width: 5),
            Text('SÉCURISÉ', style: TextStyle(color: AppColors.success, fontSize: 8, letterSpacing: .6, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}

class _BackendStatus extends StatelessWidget {
  final bool ready;
  final bool? connected;
  final bool checking;
  final VoidCallback onRetry;

  const _BackendStatus({
    required this.ready,
    required this.connected,
    required this.checking,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    final String title;
    final String subtitle;
    if (checking) {
      color = AppColors.blue;
      icon = Icons.sync_rounded;
      title = 'Vérification du service';
      subtitle = 'Connexion à I24H en cours…';
    } else if (!ready || connected == false) {
      color = AppColors.danger;
      icon = Icons.cloud_off_rounded;
      title = 'Connexion à vérifier';
      subtitle = !ready
          ? 'Le client Supabase ne s’est pas initialisé.'
          : 'Le service ne répond pas. Vérifiez Internet puis réessayez.';
    } else if (connected == true) {
      color = AppColors.success;
      icon = Icons.cloud_done_rounded;
      title = 'Service I24H connecté';
      subtitle = 'Le backend répond correctement.';
    } else {
      color = AppColors.muted;
      icon = Icons.cloud_queue_rounded;
      title = 'Service I24H prêt';
      subtitle = 'Touchez pour vérifier la connexion au serveur.';
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Row(
        children: [
          if (checking)
            SizedBox(
              width: 21,
              height: 21,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 10, height: 1.35)),
              ],
            ),
          ),
          if (!checking)
            IconButton(
              onPressed: onRetry,
              tooltip: 'Tester à nouveau',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.refresh_rounded, color: color),
            ),
        ],
      ),
    );
  }
}
