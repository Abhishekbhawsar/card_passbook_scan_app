import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/card_scan_controller.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../parsers/card_parser.dart';
import '../widgets/error_banner.dart';
import '../widgets/image_preview.dart';
import '../widgets/info_row.dart';
import '../widgets/raw_text_panel.dart';
import '../widgets/scan_action_button.dart';

class CardScannerScreen extends StatelessWidget {
  const CardScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CardScanController(),
      child: const _CardScannerView(),
    );
  }
}

class _CardScannerView extends StatelessWidget {
  const _CardScannerView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CardScanController>();
    final details = controller.cardDetails;
    final maskedNumber = details?.cardNumber == null
        ? null
        : maskCardNumber(details!.cardNumber!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Scanner', style: AppTextStyles.appBarTitle),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ImagePreview(image: controller.image),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ScanActionButton(
                  icon: Icons.photo_camera,
                  label: 'Capture card',
                  isPrimary: true,
                  onPressed: controller.isLoading ? null : controller.scanCard,
                ),
                ScanActionButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  onPressed: controller.isLoading ? null : controller.reset,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                'Reading image and parsing card details...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (controller.errorMessage != null) ...[
              ErrorBanner(message: controller.errorMessage!),
              const SizedBox(height: 12),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parsed card details',
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      label: 'Card number',
                      value: maskedNumber,
                      monospace: true,
                    ),
                    InfoRow(label: 'Expiry date', value: details?.expiryDate),
                    InfoRow(label: 'Holder name', value: details?.holderName),
                    InfoRow(
                      label: 'Luhn status',
                      value: details?.cardNumber == null ? null : 'Valid',
                    ),
                  ],
                ),
              ),
            ),
            RawTextPanel(rawText: controller.rawText),
          ],
        ),
      ),
    );
  }
}
