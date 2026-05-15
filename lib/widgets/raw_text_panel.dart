import 'package:flutter/material.dart';

class RawTextPanel extends StatelessWidget {
  const RawTextPanel({required this.rawText, super.key});

  final String rawText;

  @override
  Widget build(BuildContext context) {
    if (rawText.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('Raw OCR text'),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SelectableText(
            rawText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
