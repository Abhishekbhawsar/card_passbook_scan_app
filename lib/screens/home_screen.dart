import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'card_scanner_screen.dart';
import 'passbook_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('OCR Scanner', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Scan locally with ML Kit OCR',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 24),
            _ScannerTile(
              icon: Icons.credit_card,
              title: 'Credit / Debit Card',
              subtitle: 'Card number, expiry date, and holder name',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CardScannerScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _ScannerTile(
              icon: Icons.account_balance,
              title: 'Passbook / Bank Document',
              subtitle: 'Account holder name, account number, and IFSC code',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PassbookScannerScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerTile extends StatelessWidget {
  const _ScannerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        minVerticalPadding: 20,
        leading: Icon(icon, size: 32),
        title: Text(title, style: AppTextStyles.tileTitle),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
