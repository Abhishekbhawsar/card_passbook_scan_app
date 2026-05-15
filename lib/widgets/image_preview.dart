import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({required this.image, super.key});

  final XFile? image;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.surfaceContainerHighest,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image == null
              ? Center(
                  child: Icon(
                    Icons.document_scanner_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : Image.file(
                  File(image!.path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Text('Image preview unavailable')),
                ),
        ),
      ),
    );
  }
}
