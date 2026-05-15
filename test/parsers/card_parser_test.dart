import 'package:card_and_passbook_scan_app/parsers/card_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValidCard', () {
    test('accepts valid Luhn card numbers with spaces and dashes', () {
      expect(isValidCard('4111 1111 1111 1111'), isTrue);
      expect(isValidCard('5555-5555-5555-4444'), isTrue);
    });

    test('rejects invalid lengths and checksums', () {
      expect(isValidCard('4111 1111 1111 1112'), isFalse);
      expect(isValidCard('1234'), isFalse);
    });
  });

  group('parseCard', () {
    test('extracts separated card number, expiry, and holder name', () {
      final details = parseCard('''
HDFC BANK
VISA PLATINUM
4111 1111 1111 1111
VALID THRU 12/25
PARTH SHAH
''');

      expect(details.cardNumber, '4111111111111111');
      expect(details.expiryDate, '12/25');
      expect(details.holderName, 'PARTH SHAH');
      expect(maskCardNumber(details.cardNumber!), 'XXXX XXXX XXXX 1111');
    });

    test('handles OCR digit mistakes and compact expiry', () {
      final details = parseCard('''
MASTERCARD
5555-5555-5555-4444
VALID 1228
JANE DOE
''');

      expect(details.cardNumber, '5555555555554444');
      expect(details.expiryDate, '12/28');
      expect(details.holderName, 'JANE DOE');
    });

    test('ignores invalid card candidates', () {
      final details = parseCard('''
BANK CARD
1234 5678 9012 3456
VALID 12-25
JOHN DOE
''');

      expect(details.cardNumber, isNull);
      expect(details.expiryDate, '12/25');
      expect(details.holderName, 'JOHN DOE');
    });
  });
}
