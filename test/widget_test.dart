import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:card_and_passbook_scan_app/main.dart';

void main() {
  testWidgets('Home screen shows scanner options', (WidgetTester tester) async {
    await tester.pumpWidget(const CardAndPassbookScanApp());

    expect(find.text('OCR Scanner'), findsOneWidget);
    expect(find.byIcon(Icons.credit_card), findsOneWidget);
    expect(find.byIcon(Icons.account_balance), findsOneWidget);
  });
}
