import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/passbook_scan_controller.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../widgets/error_banner.dart';
import '../widgets/image_preview.dart';
import '../widgets/info_row.dart';
import '../widgets/raw_text_panel.dart';
import '../widgets/scan_action_button.dart';

class PassbookScannerScreen extends StatelessWidget {
  const PassbookScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PassbookScanController(),
      child: const _PassbookScannerView(),
    );
  }
}

class _PassbookScannerView extends StatelessWidget {
  const _PassbookScannerView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PassbookScanController>();
    final details = controller.bankDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passbook Scanner', style: AppTextStyles.appBarTitle),
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
                  label: 'Capture',
                  isPrimary: true,
                  onPressed: controller.isLoading
                      ? null
                      : controller.capturePassbook,
                ),
                ScanActionButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: controller.isLoading
                      ? null
                      : controller.selectPassbook,
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
                'Reading document and parsing bank details...',
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
                      'Parsed bank details',
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      label: 'Holder name',
                      value: details?.accountHolderName,
                    ),
                    InfoRow(
                      label: 'Account number',
                      value: details?.accountNumber,
                      monospace: true,
                    ),
                    InfoRow(
                      label: 'IFSC code',
                      value: details?.ifscCode,
                      monospace: true,
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
