import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class AdminPlanningScreen extends StatefulWidget {
  const AdminPlanningScreen({super.key});
  @override
  State<AdminPlanningScreen> createState() => _AdminPlanningScreenState();
}

class _AdminPlanningScreenState extends State<AdminPlanningScreen> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rows = await _client.from('programs')
          .select('id,title,description,presenter,starts_at,ends_at,is_published')
          .order('starts_at');
      if (!mounted) return;
      setState(() => _items = List<Map<String, dynamic>>.from(rows));
    } catch (e) {
      if (mounted) setState(() => _error = 'Impossible de charger le planning. Vérifiez votre connexion et vos droits administrateur.');
      debugPrint('I24H admin planning load failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  DateTime _initialDate(Map<String, dynamic>? item, String key, DateTime fallback) =>
      DateTime.tryParse('${item?[key] ?? ''}')?.toLocal() ?? fallback;

  Future<void> _edit([Map<String, dynamic>? item]) async {
    final title = TextEditingController(text: '${item?['title'] ?? ''}');
    final presenter = TextEditingController(text: '${item?['presenter'] ?? ''}');
    final description = TextEditingController(text: '${item?['description'] ?? ''}');
    var start = _initialDate(item, 'starts_at', DateTime.now().add(const Duration(hours: 1)));
    var end = _initialDate(item, 'ends_at', DateTime.now().add(const Duration(hours: 2)));
    var published = item?['is_published'] == true;
    String? validationError;

    Future<DateTime?> chooseDateTime(DateTime current) async {
      final date = await showDatePicker(context: context, initialDate: current, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)));
      if (date == null || !mounted) return null;
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(current));
      if (time == null) return null;
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }

    await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: Text(item == null ? 'Programmer un direct' : 'Modifier le créneau'),
      content: SizedBox(width: 460, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Nom de l’émission')),
        const SizedBox(height: 10),
        TextField(controller: presenter, decoration: const InputDecoration(labelText: 'Nom complet de l’animateur', helperText: 'Doit correspondre exactement au nom du profil I24H.')),
        const SizedBox(height: 10),
        TextField(controller: description, maxLines: 2, decoration: const InputDecoration(labelText: 'Description (facultatif)')),
        const SizedBox(height: 12),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.play_circle_outline), title: const Text('Début du direct'), subtitle: Text(start.toLocal().toString().substring(0, 16)), onTap: () async { final v = await chooseDateTime(start); if (v != null) setDialogState(() => start = v); }),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.stop_circle_outlined), title: const Text('Fin du direct'), subtitle: Text(end.toLocal().toString().substring(0, 16)), onTap: () async { final v = await chooseDateTime(end); if (v != null) setDialogState(() => end = v); }),
        SwitchListTile(contentPadding: EdgeInsets.zero, value: published, onChanged: (v) => setDialogState(() => published = v), title: const Text('Publier dans le programme'), subtitle: const Text('Seuls les créneaux publiés autorisent le direct.')),
        if (validationError != null) Align(alignment: Alignment.centerLeft, child: Text(validationError!, style: const TextStyle(color: AppColors.danger))),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
        FilledButton(onPressed: () async {
          if (title.text.trim().isEmpty || presenter.text.trim().isEmpty) { setDialogState(() => validationError = 'Le titre et le nom de l’animateur sont obligatoires.'); return; }
          if (!end.isAfter(start)) { setDialogState(() => validationError = 'La fin doit être après le début.'); return; }
          try {
            final payload = {
              'title': title.text.trim(),
              'presenter': presenter.text.trim(),
              'description': description.text.trim().isEmpty ? null : description.text.trim(),
              'starts_at': start.toUtc().toIso8601String(),
              'ends_at': end.toUtc().toIso8601String(),
              'is_published': published,
            };
            if (item == null) {
              await _client.from('programs').insert(payload);
            } else {
              await _client.from('programs').update(payload).eq('id', item['id']);
            }
            if (dialogContext.mounted) Navigator.pop(dialogContext);
            await _load();
          } catch (e) {
            setDialogState(() => validationError = 'Enregistrement refusé. Vérifiez que votre compte a le rôle administrateur.');
            debugPrint('I24H program save failed: $e');
          }
        }, child: const Text('Enregistrer le créneau')),
      ],
    )));
    title.dispose(); presenter.dispose(); description.dispose();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final yes = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Supprimer ce créneau ?'),
      content: Text('L’émission « ${item['title'] ?? ''} » sera retirée du planning.'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Supprimer'))],
    ));
    if (yes != true) return;
    try {
      await _client.from('programs').delete().eq('id', item['id']);
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Suppression refusée. Vérifiez vos droits administrateur.')));
      debugPrint('I24H program delete failed: $e');
    }
  }

  String _dateLabel(dynamic raw) {
    final value = DateTime.tryParse('${raw ?? ''}')?.toLocal();
    if (value == null) return 'Horaire non défini';
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')} · ${TimeOfDay.fromDateTime(value).format(context)}';
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _load,
    child: ListView(padding: const EdgeInsets.all(18), children: [
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Planning 24/7', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
          SizedBox(height: 4),
          Text('Chaque animateur ne peut diffuser que pendant son créneau publié.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ])),
        FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Programmer')),
      ]),
      const SizedBox(height: 18),
      if (_loading) const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
      if (_error != null) Padding(padding: const EdgeInsets.all(12), child: Text(_error!, style: const TextStyle(color: AppColors.danger))),
      if (!_loading && _items.isEmpty && _error == null) const Padding(padding: EdgeInsets.all(24), child: Text('Aucun créneau enregistré. Appuyez sur Programmer pour attribuer un direct à un animateur.', style: TextStyle(color: AppColors.muted))),
      ..._items.map((item) {
        final start = DateTime.tryParse('${item['starts_at'] ?? ''}')?.toLocal();
        final end = DateTime.tryParse('${item['ends_at'] ?? ''}')?.toLocal();
        final now = DateTime.now();
        final active = start != null && end != null && !now.isBefore(start) && now.isBefore(end) && item['is_published'] == true;
        return Padding(padding: const EdgeInsets.only(bottom: 10), child: I24HCard(child: Column(children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.navy.withOpacity(.07), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.schedule, color: AppColors.navy)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${item['title'] ?? 'Émission I24H'}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 4),
              Text('${_dateLabel(item['starts_at'])} — ${_dateLabel(item['ends_at'])}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 4),
              Text('Animateur : ${item['presenter'] ?? 'Non attribué'}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ])),
            StatusPill(label: active ? 'En direct' : item['is_published'] == true ? 'Programmé' : 'Brouillon', color: active ? AppColors.success : AppColors.navy),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton.icon(onPressed: () => _edit(item), icon: const Icon(Icons.edit_outlined, size: 17), label: const Text('Modifier')),
            TextButton.icon(onPressed: () => _delete(item), icon: const Icon(Icons.delete_outline, size: 17, color: AppColors.danger), label: const Text('Supprimer', style: TextStyle(color: AppColors.danger))),
          ]),
        ])));
      }),
    ]),
  );
}
