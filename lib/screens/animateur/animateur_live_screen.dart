import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AnimateurLiveScreen extends StatefulWidget {
  const AnimateurLiveScreen({super.key});

  @override
  State<AnimateurLiveScreen> createState() => _AnimateurLiveScreenState();
}

class _AnimateurLiveScreenState extends State<AnimateurLiveScreen> {
  bool live = false;
  bool mic = true;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
    children: [
      const Text('CONSOLE DE DIFFUSION', style: TextStyle(color: AppColors.blue, fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w900)),
      const SizedBox(height: 7),
      const Text('Studio I24H', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -.7)),
      const SizedBox(height: 6),
      const Text('Les commandes ci-dessous sont une maquette locale, sans diffusion réelle.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4)),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.navy, Color(0xFF163B69)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 43, height: 43, decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 24)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LE GRAND DIRECT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: .5, fontSize: 13)),
              SizedBox(height: 4),
              Text('14:00 — 18:00 · Studio A', style: TextStyle(color: Colors.white60, fontSize: 11)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: live ? AppColors.live : Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(8)), child: Text(live ? 'LIVE' : 'STANDBY', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: .8))),
          ]),
          const SizedBox(height: 28),
          Center(child: Container(
            width: 92, height: 92,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.08), border: Border.all(color: live ? AppColors.live : Colors.white24, width: 2)),
            child: Icon(live ? Icons.graphic_eq_rounded : Icons.mic_none_rounded, color: Colors.white, size: 39),
          )),
          const SizedBox(height: 15),
          Center(child: Text(live ? 'MODE DIRECT ACTIVÉ' : 'PRÊT À DIFFUSER', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.1, fontSize: 12))),
          const SizedBox(height: 5),
          Center(child: Text(live ? 'État local de démonstration' : 'Vérifiez vos sources avant le lancement', style: const TextStyle(color: Colors.white60, fontSize: 11))),
          const SizedBox(height: 24),
          _meters(),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: FilledButton.icon(
              onPressed: () => _confirmLive(),
              icon: Icon(live ? Icons.stop_rounded : Icons.play_arrow_rounded),
              label: Text(live ? 'Arrêter' : 'Démarrer'),
              style: FilledButton.styleFrom(backgroundColor: live ? AppColors.live : Colors.white, foregroundColor: live ? Colors.white : AppColors.navy),
            )),
            const SizedBox(width: 10),
            SizedBox(height: 52, width: 54, child: IconButton.filledTonal(
              onPressed: () => setState(() => mic = !mic),
              style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(.13), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              icon: Icon(mic ? Icons.mic_rounded : Icons.mic_off_rounded),
              tooltip: mic ? 'Couper le micro (maquette)' : 'Activer le micro (maquette)',
            )),
          ]),
        ]),
      ),
      const SizedBox(height: 23),
      const Text('ÉTAT DU STUDIO', style: TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
      const SizedBox(height: 11),
      I24HCard(child: Column(children: [
        _statusRow('Microphone', mic ? 'Activé · simulation' : 'Muet · simulation', mic),
        const Divider(height: 18, color: AppColors.line),
        _statusRow('Flux de diffusion', 'Non connecté', false),
        const Divider(height: 18, color: AppColors.line),
        _statusRow('Connexion serveur', 'À configurer', false),
      ])),
      const SizedBox(height: 22),
      const Text('AVANT LE DIRECT', style: TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      const _ChecklistTile(title: 'Vérifier le conducteur de l’émission', icon: Icons.checklist_rounded),
      const _ChecklistTile(title: 'Tester la source audio et le micro', icon: Icons.mic_none_rounded),
      const _ChecklistTile(title: 'Confirmer l’heure de diffusion', icon: Icons.schedule_rounded),
    ],
  );

  Widget _meters() {
    const levels = [9.0, 15.0, 22.0, 13.0, 29.0, 18.0, 34.0, 24.0, 14.0, 30.0, 20.0, 36.0, 16.0, 26.0, 11.0, 32.0, 21.0, 15.0, 28.0, 19.0, 35.0, 13.0, 24.0, 17.0, 30.0, 10.0, 22.0, 34.0, 16.0, 27.0];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Text('NIVEAU AUDIO', style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)), Spacer(), Text('VISUALISATION', style: TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: .8))]),
      const SizedBox(height: 10),
      SizedBox(height: 38, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: levels.map((h) => Container(width: 3, height: h, decoration: BoxDecoration(color: mic ? AppColors.gold.withOpacity(.45 + h / 75) : Colors.white24, borderRadius: BorderRadius.circular(4)))).toList())),
    ]);
  }

  Widget _statusRow(String title, String value, bool ok) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Icon(ok ? Icons.check_circle_rounded : Icons.info_outline_rounded, color: ok ? AppColors.success : AppColors.muted, size: 19),
      const SizedBox(width: 10),
      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
      Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(color: AppColors.muted, fontSize: 11))),
    ]),
  );

  void _confirmLive() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(live ? 'Arrêter la démonstration ?' : 'Activer le mode démonstration ?'),
        content: Text(live
          ? 'Le statut local va repasser en veille. Cela ne coupe aucun flux réel.'
          : 'Cette action change uniquement l’interface. La diffusion réelle n’est pas encore connectée.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
          FilledButton(onPressed: () { setState(() => live = !live); Navigator.pop(dialogContext); }, child: const Text('Confirmer')),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
      child: Row(children: [
        Container(width: 37, height: 37, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.blue, size: 20)),
        const SizedBox(width: 11),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
        const Icon(Icons.circle_outlined, color: AppColors.muted, size: 19),
      ]),
    ),
  );
}
