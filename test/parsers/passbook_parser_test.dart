import 'package:card_and_passbook_scan_app/parsers/passbook_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePassbook', () {
    test('extracts labeled bank document details', () {
      final details = parsePassbook('''
STATE BANK OF INDIA
Branch: Mumbai Central
Account Holder: PARTH SHAH
Account Number: 123456789012
IFSC: SBIN0001234
Mobile: 9876543210
''');

      expect(details.accountHolderName, 'PARTH SHAH');
      expect(details.accountNumber, '123456789012');
      expect(details.ifscCode, 'SBIN0001234');
    });

    test('ignores phone numbers and dates when finding account number', () {
      final details = parsePassbook('''
BANK OF BARODA
Name: JANE DOE
Date 01012024
Phone 9876543210
A/C No 001234567890123
IFSC BARB0VJTEST
''');

      expect(details.accountHolderName, 'JANE DOE');
      expect(details.accountNumber, '001234567890123');
      expect(details.ifscCode, 'BARB0VJTEST');
    });

    test('handles noisy OCR around IFSC zero', () {
      final details = parsePassbook('''
KOTAK MAHINDRA BANK
CUSTOMER NAME - RAVI KUMAR
ACCOUNT NO: 998877665544
IFSC KKBKO012345
''');

      expect(details.accountHolderName, 'RAVI KUMAR');
      expect(details.accountNumber, '998877665544');
      expect(details.ifscCode, 'KKBK0012345');
    });

    test('extracts holder name when OCR puts value on next line', () {
      final details = parsePassbook('''
UNION BANK OF INDIA
ACCOUNT HOLDER NAME
MR PARTH SHAH
A/C NO: 123456789876
IFSC UBIN0555555
''');

      expect(details.accountHolderName, 'PARTH SHAH');
      expect(details.accountNumber, '123456789876');
      expect(details.ifscCode, 'UBIN0555555');
    });

    test('extracts name from label variants without punctuation', () {
      final details = parsePassbook('''
INDIAN BANK
Name of Customer RAVI
Account Number 12345678901
IFSC IDIB000A001
''');

      expect(details.accountHolderName, 'RAVI');
      expect(details.accountNumber, '12345678901');
      expect(details.ifscCode, 'IDIB000A001');
    });

    test('extracts Bank of India passbook name with noisy name separator', () {
      final details = parsePassbook('''
Bank of India
Branch: BARNAGAR
IFSC Code : BKID0009119
Customer Id :310948188
Account No. :911910110009931
Name ? : 1. SAMPDA BHAWSAR
A/C Open Dt.: 14-08-2024
Scheme Desc: SAVINGS BANK GENERAL
Nominee : NAMITA BHAWSAR
''');

      expect(details.accountHolderName, 'SAMPDA BHAWSAR');
      expect(details.accountNumber, '911910110009931');
      expect(details.ifscCode, 'BKID0009119');
    });

    test('ignores branch name and extracts account name', () {
      final details = parsePassbook('''
Branch Name : BOPAL ROAD AHMEDABAD
Branch Email ID : boaal@bankofbaroda.com
IFSC : BARB0BOPALR
Customer ID : 070162647
Account Number : 29500100008937
Account Name : DILIPBHAI HIRABHAI RATHOD
Address : A 9 ANAND BHUVAN
A/c Opening Date : 14-02-2013
Nominee Name : Yes
''');

      expect(details.accountHolderName, 'DILIPBHAI HIRABHAI RATHOD');
      expect(details.accountNumber, '29500100008937');
      expect(details.ifscCode, 'BARB0BOPALR');
    });

    test('extracts holder name when OCR puts separator on its own line', () {
      final details = parsePassbook('''
Branch Name
BOPAL ROAD AHMEDABAD
IFSC BARB0BOPALR
Account Number
29500100008937
Account Name
:
DILIPBHAI HIRABHAI RATHOD
Address
A 9 ANAND BHUVAN
''');

      expect(details.accountHolderName, 'DILIPBHAI HIRABHAI RATHOD');
      expect(details.accountNumber, '29500100008937');
      expect(details.ifscCode, 'BARB0BOPALR');
    });

    test('extracts holder name from same OCR block before next field', () {
      final details = parsePassbook('''
Customer Id :310948188 Account No. :911910110009931
Name ? : 1. SAMPDA BHAWSAR A/C Open Dt.: 14-08-2024 Scheme Desc: SAVINGS BANK GENERAL
IFSC Code : BKID0009119
''');

      expect(details.accountHolderName, 'SAMPDA BHAWSAR');
      expect(details.accountNumber, '911910110009931');
      expect(details.ifscCode, 'BKID0009119');
    });

    test('returns nulls for partial scans without usable fields', () {
      final details = parsePassbook('''
SAVINGS ACCOUNT
BRANCH DETAILS
blur text ### 12
''');

      expect(details.accountHolderName, isNull);
      expect(details.accountNumber, isNull);
      expect(details.ifscCode, isNull);
    });
  });
}
