import 'package:flutter/material.dart';

import 'core/app_colors.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CardAndPassbookScanApp());
}

class CardAndPassbookScanApp extends StatelessWidget {
  const CardAndPassbookScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card and Passbook Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
