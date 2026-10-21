import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const reasons = [
      ('Produire de nouveaux programmes', Icons.auto_awesome_outlined),
      ('Maintenir la diffusion 24 h/24', Icons.graphic_eq_rounded),
      ('Faire grandir la communauté', Icons.diversity_3_outlined),
    ];
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 30), children: [
      const Text('Soutenir I24H', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: AppColors.ink, letterSpacing: -.6)),
      const SizedBox(height: 7),
      const Text('Chaque geste aide la prière et la parole à rester accessibles, jour et nuit.', style: TextStyle(color: AppColors.muted, height: 1.55)),
      const SizedBox(height: 22),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B2454), Color(0xFF245FE8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(color: AppColors.blue.withOpacity(.18), blurRadius: 24, offset: const Offset(0, 10))],
      ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.favorite_rounded, color: Color(0xFFFFD98A), size: 29)),
        const SizedBox(height: 19),
        const Text('Votre générosité fait la différence', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.2)),
        const SizedBox(height: 9),
        Text('Contribuez librement à la mission I24H. Chaque don compte, quel que soit son montant.', style: TextStyle(color: Colors.white.withOpacity(.88), height: 1.55, fontSize: 14)),
        const SizedBox(height: 22),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => _open(context), icon: const Icon(Icons.volunteer_activism_rounded), label: const Text('Faire un don'), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy, minimumSize: const Size.fromHeight(54)))),
        const SizedBox(height: 10),
        Center(child: Text('Don ponctuel · Montant au choix', style: TextStyle(color: Colors.white.withOpacity(.75), fontSize: 12))),
      ])),
      const SizedBox(height: 28),
      const Text('À quoi sert votre don ?', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.ink)),
      const SizedBox(height: 13),
      ...reasons.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
        child: Row(children: [
          Container(width: 43, height: 43, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(13)), child: Icon(item.$2, color: AppColors.blue)),
          const SizedBox(width: 13),
          Expanded(child: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.35))),
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
        ]),
      ))),
      const SizedBox(height: 8),
      const Text('Le paiement sécurisé sera proposé à l’étape de confirmation.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 12)),
    ]));
  }

  static void _open(BuildContext context) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (sheetContext) => _DonationAmountSheet(parentContext: context));
  }
}

class _DonationAmountSheet extends StatefulWidget {
  final BuildContext parentContext;
  const _DonationAmountSheet({required this.parentContext});
  @override
  State<_DonationAmountSheet> createState() => _DonationAmountSheetState();
}

class _DonationAmountSheetState extends State<_DonationAmountSheet> {
  final amountController = TextEditingController();
  final presets = [1000, 2500, 5000, 10000, 25000, 50000];
  int? selectedPreset;
  @override
  void dispose() { amountController.dispose(); super.dispose(); }

  void _select(int amount) {
    setState(() { selectedPreset = amount; amountController.text = amount.toString(); });
  }

  void _continue() {
    final amount = int.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saisissez un montant d’au moins 100 FCFA.')));
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(SnackBar(content: Text('Don de $amount FCFA préparé. Le paiement sera disponible après configuration du prestataire I24H.')));
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    padding: EdgeInsets.fromLTRB(22, 10, 22, MediaQuery.viewInsetsOf(context).bottom + 26),
    child: SafeArea(top: false, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(9)))),
      const SizedBox(height: 22),
      const Text('Choisissez votre montant', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink)),
      const SizedBox(height: 7),
      const Text('Sélectionnez une suggestion ou saisissez le montant de votre choix.', style: TextStyle(color: AppColors.muted, height: 1.5)),
      const SizedBox(height: 20),
      Wrap(spacing: 9, runSpacing: 9, children: presets.map((amount) {
        final selected = selectedPreset == amount;
        return ChoiceChip(label: Text('$amount F', style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.ink)), selected: selected, onSelected: (_) => _select(amount), selectedColor: AppColors.blue, backgroundColor: const Color(0xFFF5F7FC), side: BorderSide(color: selected ? AppColors.blue : AppColors.line), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9));
      }).toList()),
      const SizedBox(height: 22),
      const Text('Montant personnalisé', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
      const SizedBox(height: 9),
      TextField(controller: amountController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], onChanged: (_) => setState(() => selectedPreset = null), decoration: const InputDecoration(hintText: 'Ex. 7500', suffixText: 'FCFA', prefixIcon: Icon(Icons.payments_outlined))),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _continue, icon: const Icon(Icons.arrow_forward_rounded), label: const Text('Continuer'))),
      const SizedBox(height: 8),
      const Center(child: Text('Montant minimum : 100 FCFA', style: TextStyle(color: AppColors.muted, fontSize: 12))),
    ]))),
  );
}
