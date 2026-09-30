import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class I24HCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const I24HCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.line),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 18, offset: Offset(0, 6))],
    ),
    child: child,
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
      if (action != null)
        TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700))),
    ],
  );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const PrimaryButton({super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const StatCard({super.key, required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => I24HCard(
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppColors.navy, size: 21),
      const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.ink)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ]),
  );
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, this.color = AppColors.success});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(.09), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
  );
}
