import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livekit_client/livekit_client.dart';
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
  List<Map<String, dynamic>> invitations = [];
  bool invitationsLoading = false;
  final TextEditingController memberSearchController = TextEditingController();
  String memberSearch = '';
  List<Map<String, String>> activeMembers = [];
  bool membersLoading = false;
  final Set<String> promotingMembers = {};
  List<Map<String, dynamic>> intentions = [];
  List<Map<String, dynamic>> donations = [];
  bool activitiesLoading = false;
  String? activitiesError;

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    if (!mounted) return;
    setState(() => invitationsLoading = true);
    try {
      final rows = await Supabase.instance.client
          .from('live_guest_invitations')
          .select('id, invited_name, invited_email, invite_code, expires_at, accepted_at, created_at')
          .order('created_at', ascending: false)
          .limit(12);
      if (mounted) setState(() => invitations = List<Map<String, dynamic>>.from(rows));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de charger les invitations. Vérifiez les droits Supabase.')),
        );
      }
    } finally {
      if (mounted) setState(() => invitationsLoading = false);
    }
  }

  Future<void> _refreshActiveMembers() async {
    if (!live || liveService.room == null) {
      if (mounted) setState(() => activeMembers = []);
      return;
    }
    if (mounted) setState(() => membersLoading = true);
    try {
      final room = liveService.room!;
      final members = room.remoteParticipants.values.map((participant) => <String, String>{
        'identity': participant.identity,
        'name': participant.name.isNotEmpty ? participant.name : participant.identity,
      }).toList()..sort((a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()));
      if (mounted) setState(() => activeMembers = members);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de récupérer les auditeurs connectés.')));
    } finally {
      if (mounted) setState(() => membersLoading = false);
    }
  }

  Future<void> _promoteMember(Map<String, String> member) async {
    final identity = member['identity'] ?? '';
    if (identity.isEmpty || promotingMembers.contains(identity)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Faire monter ce membre ?'),
        content: Text('${member['name']} pourra prendre la parole dans le direct. Assurez-vous qu’il est prêt à activer son micro.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Faire monter')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => promotingMembers.add(identity));
    try {
      await liveService.promoteParticipant(identity);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${member['name']} peut maintenant prendre la parole.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))));
    } finally {
      if (mounted) setState(() => promotingMembers.remove(identity));
    }
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

  VideoTrack? get _localCameraTrack {
    final participant = liveService.room?.localParticipant;
    if (participant == null) return null;
    for (final publication in participant.videoTrackPublications) {
      final track = publication.track;
      if (track is VideoTrack) return track;
    }
    return null;
  }

  Future<void> _toggleLive() async {
    if (busy) return;
    setState(() { busy = true; liveError = null; });
    try {
      if (live) {
        await liveService.disconnect();
        if (mounted) setState(() { live = false; mic = false; camera = false; screenShare = false; activeMembers = []; });
      } else {
        final user = Supabase.instance.client.auth.currentUser;
        final displayName = (user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? 'Animateur I24H').toString();
        await liveService.connect(participantName: displayName, publishAudio: true);
        if (mounted) setState(() { live = true; mic = true; liveError = null; });
        await _refreshActiveMembers();
      }
    } catch (error) {
      if (mounted) setState(() { live = false; liveError = error.toString().replaceFirst('Bad state: ', ''); });
      await liveService.disconnect();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _toggleCamera() async {
    if (!live) { setState(() => liveError = 'Démarrez le direct avant d’activer la caméra.'); return; }
    try {
      final enabled = !camera;
      await liveService.setCameraEnabled(enabled);
      if (mounted) setState(() { camera = enabled; liveError = null; });
    } catch (error) {
      if (mounted) setState(() => liveError = error.toString().replaceFirst('Bad state: ', ''));
    }
  }

  Future<void> _toggleScreenShare() async { if (!live) { setState(() => liveError = 'Démarrez le direct avant de partager l’écran.'); return; } try { await liveService.setScreenShareEnabled(!screenShare); if (mounted) setState(() { screenShare = !screenShare; liveError = null; }); } catch (error) { if (mounted) setState(() => liveError = error.toString().replaceFirst('Bad state: ', '')); } }

  Future<void> _toggleMic() async { if (!live) { setState(() => liveError = 'Démarrez le direct avant de modifier le micro.'); return; } try { await liveService.setMicrophoneEnabled(!mic); if (mounted) setState(() { mic = !mic; liveError = null; }); } catch (error) { if (mounted) setState(() => liveError = error.toString().replaceFirst('Bad state: ', '')); } }

  @override
  void dispose() { memberSearchController.dispose(); liveService.disconnect(); super.dispose(); }

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
              await _loadInvitations();
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
            ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.white.withOpacity(.1))),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (camera && _localCameraTrack != null)
                      VideoTrackRenderer(_localCameraTrack!, fit: VideoViewFit.cover)
                    else
                      Container(
                        color: const Color(0xFF0B1B32),
                        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(camera ? Icons.videocam_off_rounded : Icons.videocam_rounded, size: 42, color: Colors.white70),
                          const SizedBox(height: 10),
                          Text(camera ? 'Caméra activée — aperçu en préparation' : 'Activez la caméra pour voir votre aperçu', style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
                        ])),
                      ),
                    Positioned(left: 12, top: 12, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(color: live ? Colors.red.withOpacity(.9) : Colors.black54, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.circle, color: Colors.white, size: 7),
                        const SizedBox(width: 6),
                        Text(live ? 'EN DIRECT' : 'APERÇU STUDIO', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                      ]),
                    )),
                    if (camera && _localCameraTrack != null)
                      const Positioned(right: 10, bottom: 10, child: Icon(Icons.flip_camera_android_rounded, color: Colors.white70, size: 18)),
                  ],
                ),
              ),
            ),
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
        final guestPanel = Column(children: [
          I24HCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: SectionTitle(title: 'Auditeurs en direct')),
              IconButton(onPressed: membersLoading ? null : _refreshActiveMembers, tooltip: 'Actualiser les membres connectés', icon: const Icon(Icons.refresh_rounded)),
            ]),
            const Text('Recherchez les membres présents dans le direct et faites-les monter sur scène pour qu’ils puissent parler.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4)),
            const SizedBox(height: 12),
            TextField(
              controller: memberSearchController,
              onChanged: (value) => setState(() => memberSearch = value.trim().toLowerCase()),
              decoration: const InputDecoration(labelText: 'Rechercher un auditeur', prefixIcon: Icon(Icons.search_rounded), hintText: 'Nom ou identifiant'),
            ),
            const SizedBox(height: 10),
            if (!live) const Padding(padding: EdgeInsets.all(10), child: Text('Démarrez le direct pour voir les auditeurs connectés.', style: TextStyle(color: AppColors.muted)))
            else if (membersLoading && activeMembers.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator()))
            else if (activeMembers.where((m) => ('${m['name']} ${m['identity']}').toLowerCase().contains(memberSearch)).isEmpty)
              const Padding(padding: EdgeInsets.all(10), child: Text('Aucun auditeur correspondant. Actualisez la liste si quelqu’un vient de rejoindre.', style: TextStyle(color: AppColors.muted)))
            else ...activeMembers.where((m) => ('${m['name']} ${m['identity']}').toLowerCase().contains(memberSearch)).map((member) {
              final identity = member['identity']!;
              final isPromoting = promotingMembers.contains(identity);
              return Padding(padding: const EdgeInsets.only(bottom: 8), child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF6F8FC), borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const CircleAvatar(backgroundColor: AppColors.sky, child: Icon(Icons.headphones_rounded, color: AppColors.blue)),
                  const SizedBox(width: 9),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(member['name']!, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
                    Text('Auditeur connecté', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                  ])),
                  const SizedBox(width: 6),
                  FilledButton.tonalIcon(
                    onPressed: isPromoting ? null : () => _promoteMember(member),
                    icon: isPromoting ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.mic_rounded, size: 17),
                    label: const Text('Faire monter'),
                  ),
                ]),
              ));
            }),
          ])),
          const SizedBox(height: 12),
          I24HCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: SectionTitle(title: 'Invitations au direct')),
            IconButton(onPressed: invitationsLoading ? null : _loadInvitations, tooltip: 'Actualiser', icon: const Icon(Icons.refresh_rounded)),
            IconButton.filledTonal(onPressed: _invite, icon: const Icon(Icons.person_add_alt_1_rounded), tooltip: 'Inviter un participant'),
          ]),
          const SizedBox(height: 5),
          const Text('Les codes permettent aux personnes invitées de prendre la parole. Ils expirent après 24 heures.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4)),
          const SizedBox(height: 12),
          if (invitationsLoading && invitations.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator()))
          else if (invitations.isEmpty)
            const Padding(padding: EdgeInsets.all(12), child: Text('Aucune invitation créée. Appuyez sur + pour inviter un membre.', style: TextStyle(color: AppColors.muted)))
          else
            ...invitations.map((invite) {
              final expiry = DateTime.tryParse(invite['expires_at']?.toString() ?? '')?.toLocal();
              final accepted = invite['accepted_at'] != null;
              final expired = expiry == null || expiry.isBefore(DateTime.now());
              final status = accepted ? 'Utilisée' : expired ? 'Expirée' : 'En attente';
              final statusColor = accepted ? AppColors.success : expired ? AppColors.danger : AppColors.blue;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF6F8FC), borderRadius: BorderRadius.circular(15)),
                  child: Row(children: [
                    CircleAvatar(backgroundColor: AppColors.sky, child: const Icon(Icons.person_outline_rounded, color: AppColors.blue)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text((invite['invited_name'] ?? 'Membre invité').toString(), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 3),
                      Text((invite['invited_email'] ?? '').toString(), style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                      const SizedBox(height: 5),
                      Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800)),
                    ])),
                    IconButton(
                      onPressed: accepted || expired ? null : () async {
                        await Clipboard.setData(ClipboardData(text: (invite['invite_code'] ?? '').toString()));
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code d’invitation copié.')));
                      },
                      tooltip: 'Copier le code',
                      icon: const Icon(Icons.copy_rounded, color: AppColors.blue),
                    ),
                  ]),
                ),
              );
            }),
        ])),
        ]);
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
