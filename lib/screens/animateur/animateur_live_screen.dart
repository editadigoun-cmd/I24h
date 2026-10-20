import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/i24h_live_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AnimateurLiveScreen extends StatefulWidget {
  const AnimateurLiveScreen({super.key});
  @override
  State<AnimateurLiveScreen> createState() => _AnimateurLiveScreenState();
}

class _AnimateurLiveScreenState extends State<AnimateurLiveScreen> {
  bool live = false;
  bool mic = false;
  bool busy = false;
  String? liveError;
  final I24HLiveService liveService = I24HLiveService();
  bool camera = false;
  bool screenShare = false;
  int tab = 0;
  final guests = <Map<String, dynamic>>[
    {'name': 'Invité de démonstration', 'role': 'Invité', 'mic': false, 'camera': false},
  ];
  List<Map<String, dynamic>> intentions = [];
  List<Map<String, dynamic>> donations = [];
  bool activitiesLoading = false;
  String? activitiesError;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (!mounted) return;
    setState(() { activitiesLoading = true; activitiesError = null; });
    try {
      final supabase = Supabase.instance.client;
      final intentionRows = await supabase
          .from('prayer_intentions')
          .select('id, message, status, created_at, is_private')
          .order('created_at', ascending: false)
          .limit(8);
      List<Map<String, dynamic>> donationRows = [];
      try {
        final rows = await supabase
            .from('donations')
            .select('amount_xof, status, created_at')
            .eq('status', 'succeeded')
            .order('created_at', ascending: false)
            .limit(8);
        donationRows = List<Map<String, dynamic>>.from(rows);
      } catch (_) {
        // Non-admin staff are intentionally not allowed to read donation records.
      }
      if (!mounted) return;
      setState(() {
        intentions = List<Map<String, dynamic>>.from(intentionRows);
        donations = donationRows;
      });
    } catch (error) {
      if (mounted) setState(() => activitiesError = 'Impossible de charger les données du studio. Vérifiez les droits du compte.');
    } finally {
      if (mounted) setState(() => activitiesLoading = false);
    }
  }

  String _relativeDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return 'Date inconnue';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l’instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }

  String _intentionStatus(dynamic value) {
    switch (value?.toString()) {
      case 'in_prayer': return 'En prière';
      case 'answered': return 'Exaucée';
      case 'archived': return 'Archivée';
      default: return 'À prendre en charge';
    }
  }

  Future<void> _toggleLive() async { if (busy) return; setState(() { busy = true; liveError = null; }); try { if (live) { await liveService.disconnect(); if (mounted) setState(() { live = false; mic = false; camera = false; }); } else { final user = Supabase.instance.client.auth.currentUser; final displayName = (user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? 'Animateur I24H').toString(); await liveService.connect(participantName: displayName, publishAudio: true); if (mounted) setState(() { live = true; mic = true; }); } } catch (error) { if (mounted) setState(() => liveError = error.toString().replaceFirst('Bad state: ', '')); } finally { if (mounted) setState(() => busy = false); } }

  Future<void> _toggleCamera() async { if (!live) { setState(() => liveError = 'Démarrez le direct avant d’activer la caméra.'); return; } try { await liveService.setCameraEnabled(!camera); if (mounted) setState(() { camera = !camera; liveError = null; }); } catch (error) { if (mounted) setState(() => liveError = error.toString().replaceFirst('Bad state: ', '')); } }

  Future<void> _toggleScreenShare() async { if (!live) { setState(() => liveError = 'Démarrez le direct avant de partager l’écran.'); return; } try { await liveService.setScreenShareEnabled(!screenShare); if (mounted) setState(() { screenShare = !screenShare; liveError = null; }); } catch (error) { if (mounted) setState(() => liveError = error.toString().replaceFirst('Bad state: ', '')); } }

  Future<void> _toggleMic() async { if (!live) { setState(() => liveError = 'Démarrez le direct avant de modifier le micro.'); return; } try { await liveService.setMicrophoneEnabled(!mic); if (mounted) setState(() { mic = !mic; liveError = null; }); } catch (error) { if (mounted) setState(() => liveError = error.toString().replaceFirst('Bad state: ', '')); } }

  @override
  void dispose() { liveService.disconnect(); super.dispose(); }

  Future<void> _invite() async {
    final name = TextEditingController();
    final email = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Inviter un membre au direct'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nom de l’invité', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 12),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Adresse e-mail du compte I24H', prefixIcon: Icon(Icons.mail_outline))),
          const SizedBox(height: 10),
          const Text('L’invité doit se connecter à I24H avec cette adresse, puis saisir le code pour parler dans le direct.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
          FilledButton(onPressed: () async {
            final guestName = name.text.trim();
            final guestEmail = email.text.trim().toLowerCase();
            if (guestName.isEmpty || !guestEmail.contains('@') || guestEmail.endsWith('@')) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Renseignez un nom et une adresse e-mail valide.')));
              return;
            }
            final user = Supabase.instance.client.auth.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connectez-vous pour créer une invitation.')));
              return;
            }
            final code = List<int>.generate(32, (_) => Random.secure().nextInt(256)).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
            try {
              await Supabase.instance.client.from('live_guest_invitations').insert({
                'invited_by': user.id,
                'invited_email': guestEmail,
                'invited_name': guestName,
                'invite_code': code,
                'expires_at': DateTime.now().toUtc().add(const Duration(hours: 24)).toIso8601String(),
              });
              if (!mounted) return;
              Navigator.pop(dialogContext);
              await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
                title: const Text('Invitation créée'),
                content: SelectableText('Membre : $guestName\nE-mail : $guestEmail\n\nCode valable 24 h :\n$code\n\nEnvoyez ce code à la personne. Elle doit utiliser un compte I24H associé à cette adresse e-mail.'),
                actions: [
                  TextButton(onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code d’invitation copié.')));
                  }, child: const Text('Copier le code')),
                  FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
                ],
              ));
            } catch (error) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Création impossible : $error')));
            }
          }, child: const Text('Créer l’invitation')),
        ],
      ),
    );
    name.dispose();
    email.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return ListView(padding: EdgeInsets.all(wide ? 28 : 18), children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Studio de diffusion', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: AppColors.ink, letterSpacing: -.7)),
          SizedBox(height: 6),
          Text('Préparez votre émission, gérez les invités et suivez la communauté en direct.', style: TextStyle(color: AppColors.muted, height: 1.5)),
        ])),
        const SizedBox(width: 10),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: live ? const Color(0xFFFFE9E7) : AppColors.sky, borderRadius: BorderRadius.circular(12)), child: Row(children: [
          Icon(Icons.circle, size: 9, color: live ? AppColors.danger : AppColors.blue),
          const SizedBox(width: 7),
          Text(live ? 'EN DIRECT' : 'HORS LIGNE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: live ? AppColors.danger : AppColors.blue, letterSpacing: .5)),
        ])),
      ]),
      const SizedBox(height: 22),
      LayoutBuilder(builder: (context, constraints) {
        final studio = Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF07152E), Color(0xFF16386D)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(25)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.graphic_eq_rounded, color: AppColors.cyan, size: 24)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('LE GRAND DIRECT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                SizedBox(height: 3),
                Text('Studio principal · Diffusion I24H', style: TextStyle(color: Color(0xFFB8C9E5), fontSize: 12)),
              ])),
              if (live) const StatusPill(label: 'ON AIR', color: AppColors.danger),
            ]),
            const SizedBox(height: 25),
            Container(height: 180, width: double.infinity, decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(19), border: Border.all(color: Colors.white.withOpacity(.1))), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 70, height: 70, decoration: BoxDecoration(color: camera ? AppColors.blue.withOpacity(.35) : Colors.white.withOpacity(.09), shape: BoxShape.circle), child: Icon(camera ? Icons.videocam_rounded : Icons.mic_rounded, size: 32, color: Colors.white)),
              const SizedBox(height: 13),
              Text(camera ? 'CAMÉRA ACTIVÉE' : 'APERÇU DU STUDIO', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              const SizedBox(height: 5),
              Text(live ? 'Votre émission est marquée comme en direct' : 'Activez vos équipements avant de démarrer', style: const TextStyle(color: Color(0xFFB8C9E5), fontSize: 11), textAlign: TextAlign.center),
            ]))),
            const SizedBox(height: 18),
            Wrap(spacing: 9, runSpacing: 9, children: [
              FilledButton.icon(onPressed: busy ? null : _toggleLive, style: FilledButton.styleFrom(backgroundColor: live ? AppColors.danger : AppColors.success, foregroundColor: Colors.white), icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(live ? Icons.stop_rounded : Icons.sensors_rounded), label: Text(busy ? 'Connexion…' : live ? 'Terminer le direct' : 'Démarrer le direct')),
              OutlinedButton.icon(onPressed: busy ? null : _toggleMic, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: mic ? Colors.white38 : AppColors.danger)), icon: Icon(mic ? Icons.mic_rounded : Icons.mic_off_rounded), label: Text(mic ? 'Micro actif' : 'Micro coupé')),
              OutlinedButton.icon(onPressed: busy ? null : _toggleCamera, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38)), icon: Icon(camera ? Icons.videocam_rounded : Icons.videocam_off_rounded), label: Text(camera ? 'Caméra active' : 'Caméra coupée')),
              OutlinedButton.icon(onPressed: busy ? null : _toggleScreenShare, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38)), icon: Icon(screenShare ? Icons.stop_screen_share_rounded : Icons.screen_share_rounded), label: Text(screenShare ? 'Arrêter partage' : 'Partager écran')),
            ]),
            const SizedBox(height: 13),
            Text(live ? 'Connecté à LiveKit : votre micro diffuse dans le salon I24H.' : 'Le direct utilise LiveKit. Autorisez l’accès au micro lorsque le téléphone le demande.', style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 11, height: 1.5)),
            if (liveError != null) ...[ const SizedBox(height: 10), Text(liveError!, style: const TextStyle(color: Color(0xFFFFB4AB), fontSize: 12, height: 1.4)), ],
          ]),
        );
        final guestPanel = I24HCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Expanded(child: SectionTitle(title: 'Invités du direct')), IconButton.filledTonal(onPressed: _invite, icon: const Icon(Icons.person_add_alt_1_rounded), tooltip: 'Inviter un participant')]),
          const SizedBox(height: 8),
          ...guests.map((guest) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF6F8FC), borderRadius: BorderRadius.circular(15)), child: Row(children: [
            CircleAvatar(backgroundColor: AppColors.sky, child: const Icon(Icons.person_rounded, color: AppColors.blue)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(guest['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)), const SizedBox(height: 3), Text(guest['role'] as String, style: const TextStyle(color: AppColors.muted, fontSize: 12))])),
            IconButton(onPressed: () => setState(() => guest['mic'] = !(guest['mic'] as bool)), tooltip: (guest['mic'] as bool) ? 'Couper le micro' : 'Activer le micro', icon: Icon((guest['mic'] as bool) ? Icons.mic_rounded : Icons.mic_off_rounded, color: (guest['mic'] as bool) ? AppColors.success : AppColors.danger)),
            IconButton(onPressed: () => setState(() => guest['camera'] = !(guest['camera'] as bool)), tooltip: (guest['camera'] as bool) ? 'Couper la caméra' : 'Activer la caméra', icon: Icon((guest['camera'] as bool) ? Icons.videocam_rounded : Icons.videocam_off_rounded, color: AppColors.blue)),
            IconButton(onPressed: () => setState(() => guests.remove(guest)), tooltip: 'Retirer l’invité', icon: const Icon(Icons.person_remove_alt_1_rounded, color: AppColors.danger)),
          ])))),
          if (guests.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('Aucun invité pour le moment.', style: TextStyle(color: AppColors.muted))),
        ]));
        if (constraints.maxWidth >= 1000) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 7, child: studio),
          const SizedBox(width: 18),
          Expanded(flex: 4, child: guestPanel),
        ]);
        return Column(children: [studio, const SizedBox(height: 16), guestPanel]);
      }),
      const SizedBox(height: 22),
      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line)), child: Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [
          Expanded(child: _tabButton('Intentions de prière', Icons.volunteer_activism_outlined, 0)),
          Expanded(child: _tabButton('Dons reçus', Icons.favorite_border_rounded, 1)),
        ])),
        const Divider(height: 1, color: AppColors.line),
        Padding(padding: const EdgeInsets.all(16), child: activitiesLoading
          ? const Padding(padding: EdgeInsets.all(22), child: Center(child: CircularProgressIndicator()))
          : activitiesError != null
              ? Column(children: [Text(activitiesError!, style: const TextStyle(color: AppColors.danger)), TextButton.icon(onPressed: _loadActivities, icon: const Icon(Icons.refresh), label: const Text('Réessayer'))])
              : tab == 0
                  ? intentions.isEmpty
                      ? const Padding(padding: EdgeInsets.all(16), child: Text('Aucune intention reçue pour le moment.', style: TextStyle(color: AppColors.muted)))
                      : Column(children: intentions.map((item) {
                          final status = _intentionStatus(item['status']);
                          final message = (item['message'] ?? 'Intention sans texte').toString();
                          final title = message.length > 70 ? '${message.substring(0, 67)}…' : message;
                          return Padding(padding: const EdgeInsets.only(bottom: 10), child: _activityRow(Icons.mark_chat_unread_outlined, title, _relativeDate(item['created_at']), status, status == 'En prière' ? AppColors.success : AppColors.blue));
                        }).toList())
                  : donations.isEmpty
                      ? const Padding(padding: EdgeInsets.all(16), child: Text('Aucun don confirmé accessible à ce compte.', style: TextStyle(color: AppColors.muted)))
                      : Column(children: donations.map((item) {
                          final amount = (item['amount_xof'] as num?)?.toInt() ?? 0;
                          return Padding(padding: const EdgeInsets.only(bottom: 10), child: _activityRow(Icons.favorite_rounded, 'Don confirmé', _relativeDate(item['created_at']), '${amount.toString()} FCFA', AppColors.success));
                        }).toList())),
      ])),
      const SizedBox(height: 12),
      const Text('Les intentions proviennent de Supabase. Les dons affichés sont les paiements confirmés et ne sont visibles qu’aux comptes administrateurs.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5)),
    ]);
  }

  Widget _tabButton(String label, IconData icon, int value) {
    final selected = tab == value;
    return TextButton.icon(onPressed: () => setState(() => tab = value), icon: Icon(icon, size: 18, color: selected ? AppColors.blue : AppColors.muted), label: Text(label, style: TextStyle(color: selected ? AppColors.blue : AppColors.muted, fontWeight: FontWeight.w800, fontSize: 12)));
  }

  Widget _activityRow(IconData icon, String title, String subtitle, String trailing, Color color) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: const Color(0xFFF7F9FD), borderRadius: BorderRadius.circular(15)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted))])),
      const SizedBox(width: 8),
      Text(trailing, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
    ]),
  );
}
