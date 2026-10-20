import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AdminAnimateursScreen extends StatefulWidget {
  const AdminAnimateursScreen({super.key});
  @override
  State<AdminAnimateursScreen> createState() => _AdminAnimateursScreenState();
}

class _AdminAnimateursScreenState extends State<AdminAnimateursScreen> {
  final search = TextEditingController();
  final items = <Map<String, String>>[
    {'name': 'Edith A.', 'email': 'edith@i24h.org', 'specialty': 'Prière & enseignement', 'status': 'Actif'},
    {'name': 'Chadrac T.', 'email': 'chadrac@i24h.org', 'specialty': 'Animation & témoignages', 'status': 'Actif'},
    {'name': 'Ruth K.', 'email': 'ruth@i24h.org', 'specialty': 'Accompagnement spirituel', 'status': 'Actif'},
    {'name': 'Paul D.', 'email': 'paul@i24h.org', 'specialty': 'Émissions & débats', 'status': 'En pause'},
  ];

  @override
  void dispose() { search.dispose(); super.dispose(); }

  void _addAnimator() {
    final name = TextEditingController();
    final email = TextEditingController();
    final specialty = TextEditingController();
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Créer un profil animateur'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Nom complet', prefixIcon: Icon(Icons.person_outline))),
        const SizedBox(height: 12),
        TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Adresse e-mail professionnelle', prefixIcon: Icon(Icons.mail_outline))),
        const SizedBox(height: 12),
        TextField(controller: specialty, decoration: const InputDecoration(labelText: 'Spécialité / rôle', prefixIcon: Icon(Icons.mic_none_rounded))),
        const SizedBox(height: 12),
        const Text('Cette interface prépare la fiche. La création sécurisée du compte et l’envoi du mot de passe temporaire doivent être reliés à une fonction serveur Supabase.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.45)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
        FilledButton.icon(onPressed: () {
          if (name.text.trim().length < 2 || !email.text.contains('@')) return;
          setState(() => items.insert(0, {'name': name.text.trim(), 'email': email.text.trim(), 'specialty': specialty.text.trim().isEmpty ? 'Animateur' : specialty.text.trim(), 'status': 'À inviter'}));
          Navigator.pop(dialogContext);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fiche animateur ajoutée à la liste de préparation.')));
        }, icon: const Icon(Icons.person_add_alt_1_rounded), label: const Text('Créer la fiche')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = items.where((item) => ('${item['name']} ${item['email']} ${item['specialty']}').toLowerCase().contains(search.text.toLowerCase())).toList();
    final wide = MediaQuery.sizeOf(context).width >= 800;
    return ListView(padding: EdgeInsets.all(wide ? 28 : 18), children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gestion des animateurs', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.ink, letterSpacing: -.6)),
          SizedBox(height: 6),
          Text('Gérez l’équipe, les rôles et l’accès au studio I24H.', style: TextStyle(color: AppColors.muted, height: 1.5)),
        ])),
        const SizedBox(width: 10),
        FilledButton.icon(onPressed: _addAnimator, icon: const Icon(Icons.person_add_alt_1_rounded), label: const Text('Ajouter')),
      ]),
      const SizedBox(height: 22),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: wide ? 3 : 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: wide ? 2.5 : 1.65, children: [
        const StatCard(value: '04', label: 'Animateurs', icon: Icons.groups_rounded),
        StatCard(value: items.where((x) => x['status'] == 'Actif').length.toString().padLeft(2, '0'), label: 'Actifs', icon: Icons.verified_user_outlined),
        StatCard(value: items.where((x) => x['status'] != 'Actif').length.toString().padLeft(2, '0'), label: 'À suivre', icon: Icons.schedule_rounded),
      ]),
      const SizedBox(height: 22),
      TextField(controller: search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Rechercher par nom, e-mail ou spécialité…', prefixIcon: Icon(Icons.search_rounded))),
      const SizedBox(height: 14),
      ...filtered.map((item) {
        final active = item['status'] == 'Actif';
        return Padding(padding: const EdgeInsets.only(bottom: 12), child: I24HCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF17396C), AppColors.blue]), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(item['name']!.split(' ').map((x) => x.isNotEmpty ? x[0] : '').take(2).join(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)))),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink, fontSize: 16)),
            const SizedBox(height: 4),
            Text(item['email']!, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 7),
            Text(item['specialty']!, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 9),
            StatusPill(label: item['status']!, color: active ? AppColors.success : AppColors.gold),
          ])),
          PopupMenuButton<String>(tooltip: 'Actions', onSelected: (value) {
            setState(() {
              if (value == 'toggle') item['status'] = active ? 'En pause' : 'Actif';
              if (value == 'remove') items.remove(item);
            });
            if (value == 'invite') ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('L’envoi d’invitation sera activé après connexion à Supabase Edge Functions.')));
          }, itemBuilder: (_) => const [
            PopupMenuItem(value: 'invite', child: Text('Envoyer une invitation')),
            PopupMenuItem(value: 'toggle', child: Text('Activer / mettre en pause')),
            PopupMenuItem(value: 'remove', child: Text('Retirer de la liste')),
          ]),
        ])));
      }),
      if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Aucun animateur ne correspond à cette recherche.', style: TextStyle(color: AppColors.muted)))),
      const SizedBox(height: 8),
      const Text('Les fiches affichées sont actuellement des données de démonstration locales. Les comptes, rôles et invitations devront être créés côté serveur pour garantir la sécurité.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5)),
    ]);
  }
}
