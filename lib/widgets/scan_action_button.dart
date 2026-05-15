import 'package:flutter/material.dart';

class ScanActionButton extends StatelessWidget {
  const ScanActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );

    if (isPrimary) {
      return FilledButton(onPressed: onPressed, child: child);
    }
    return OutlinedButton(onPressed: onPressed, child: child);
  }
}
