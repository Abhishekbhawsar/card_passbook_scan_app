import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.label,
    required this.value,
    this.monospace = false,
    super.key,
  });

  final String label;
  final String? value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final displayValue = value == null || value!.isEmpty ? 'Not found' : value!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: textTheme.bodyLarge?.copyWith(
                fontFamily: monospace ? 'monospace' : null,
                fontWeight: FontWeight.w600,
                color: value == null || value!.isEmpty
                    ? colorScheme.error
                    : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
