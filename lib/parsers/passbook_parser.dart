
import '../models/bank_details.dart';
import '../utils/text_cleanup.dart';

// const Set<String> _bankNameStopWords = {
//   'BANK',
//   'IFSC',
//   'ACCOUNT',
//   'A/C',
//   'ACCT',
//   'BRANCH',
//   'SAVINGS',
//   'CURRENT',
//   'CUSTOMER',
//   'CIF',
//   'MICR',
//   'ADDRESS',
//   'PHONE',
//   'MOBILE',
//   'NOMINEE',
// };



const Set<String> _bankNameStopWords = {
  'BANK',
  'IFSC',
  'ACCOUNT',
  'A/C',
  'ACCT',
  'BRANCH',
  'SAVINGS',
  'CURRENT',
  'CUSTOMER',
  'CIF',
  'MICR',
  'ADDRESS',
  'PHONE',
  'MOBILE',
  'NOMINEE',
};

final RegExp _nameLabelPattern = RegExp(
  r'\b(?:CUSTOMER NAME|NAME OF CUSTOMER|ACCOUNT HOLDER NAME|ACCOUNT HOLDER|A/C HOLDER|HOLDER NAME|ACCOUNT NAME|NAME OF A/C HOLDER|NAME)\b',
  caseSensitive: false,
);

final RegExp _nonHolderNameLabelPattern = RegExp(
  r'\b(?:BRANCH NAME|NOMINEE NAME|FATHER NAME|MOTHER NAME|GUARDIAN NAME|ADDRESS|EMAIL|PHONE|TEL)\b',
  caseSensitive: false,
);

final RegExp _nextFieldLabelPattern = RegExp(
  r'\b(?:ACCOUNT NUMBER|ACCOUNT NO|A/C NO|ACC NO|CUSTOMER ID|CUST ID|IFSC|MICR|ADDRESS|BRANCH|NOMINEE|SCHEME|A/C OPEN|ACCOUNT OPEN|OPENING DATE|MOBILE|PHONE|EMAIL|TEL|DATE)\b',
  caseSensitive: false,
);

BankDetails parsePassbook(String rawText) {
  final lines = normalizedLines(rawText);
  final searchableText = rawText.toUpperCase();

  return BankDetails(
    accountHolderName: _extractAccountHolderName(lines),
    accountNumber: _extractAccountNumber(searchableText),
    ifscCode: _extractIfsc(searchableText),
  );
}

String? _extractIfsc(String rawText) {
  // IFSC's fifth character is always zero, but OCR often reads it as letter O.
  final match = RegExp(r'\b[A-Z]{4}[0O][A-Z0-9]{6}\b').firstMatch(rawText);
  return match?.group(0)?.replaceRange(4, 5, '0');
}

String? _extractAccountNumber(String rawText) {
  // Labeled values are safer than free-floating numbers, so check them first.
  final labeledPattern = RegExp(
    r'(?:ACCOUNT NUMBER|ACCOUNT NO|ACC NO|A/C|AC|ACCOUNT)[^0-9OISL|]{0,20}([0-9OISL|][0-9OISL|\s-]{7,24}[0-9OISL|])',
    caseSensitive: false,
  );
  for (final match in labeledPattern.allMatches(rawText)) {
    final candidate = _cleanAccountCandidate(match.group(1)!);
    if (_isLikelyAccountNumber(candidate)) {
      return candidate;
    }
  }

  final candidates =
      RegExp(
            r'(?<![0-9OISL|])[0-9OISL|][0-9OISL|\s-]{7,24}[0-9OISL|](?![0-9OISL|])',
            caseSensitive: false,
          )
          .allMatches(rawText)
          .map((match) => _cleanAccountCandidate(match.group(0)!))
          .where(_isLikelyAccountNumber)
          .toList();

  if (candidates.isEmpty) {
    return null;
  }
  candidates.sort((a, b) => b.length.compareTo(a.length));
  return candidates.first;
}

String _cleanAccountCandidate(String value) {
  return normalizeOcrDigits(value).replaceAll(RegExp(r'[\s-]'), '');
}

bool _isLikelyAccountNumber(String value) {
  if (!RegExp(r'^\d{9,18}$').hasMatch(value)) {
    return false;
  }
  // Reject common OCR noise before accepting an unlabeled long number.
  if (RegExp(r'^(\d)\1+$').hasMatch(value)) {
    return false;
  }
  if (_looksLikePhoneNumber(value) || _looksLikeDate(value)) {
    return false;
  }
  return true;
}

bool _looksLikePhoneNumber(String value) {
  return value.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(value);
}

bool _looksLikeDate(String value) {
  if (value.length == 8) {
    final day = int.tryParse(value.substring(0, 2));
    final month = int.tryParse(value.substring(2, 4));
    final year = int.tryParse(value.substring(4));
    return day != null &&
        month != null &&
        year != null &&
        day >= 1 &&
        day <= 31 &&
        month >= 1 &&
        month <= 12 &&
        year >= 1900 &&
        year <= 2099;
  }
  return false;
}

String? _extractAccountHolderName(List<String> lines) {
  final labeledName = _extractLabeledName(lines);
  if (labeledName != null) {
    return labeledName;
  }

  for (final line in lines) {
    final candidate = _cleanNameLine(line);
    if (_looksLikeBankCustomerName(candidate)) {
      return candidate;
    }
  }

  return null;
}

String? _extractLabeledName(List<String> lines) {
  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    final match = _nameLabelPattern.firstMatch(line);
    if (match == null) {
      continue;
    }
    if (_isNonHolderNameLabel(line, match.start)) {
      continue;
    }

    final sameLineText = _valueBeforeNextField(line.substring(match.end));
    final candidate = _cleanNameLine(_stripLabelSeparator(sameLineText));
    if (_looksLikeBankCustomerName(candidate, allowSingleWord: true)) {
      return candidate;
    }

    // OCR often breaks a label and its value across nearby lines:
    final nearbyCandidate = _extractNearbyName(lines, index + 1);
    if (nearbyCandidate != null) {
      return nearbyCandidate;
    }
  }

  return null;
}

bool _isNonHolderNameLabel(String line, int holderLabelStart) {
  final blockedMatch = _nonHolderNameLabelPattern.firstMatch(line);
  return blockedMatch != null && blockedMatch.start <= holderLabelStart;
}

String _stripLabelSeparator(String value) {
  return value.replaceFirst(RegExp(r'^[\s:;?\-.|0-9]+'), '');
}

String _valueBeforeNextField(String value) {
  final nextField = _nextFieldLabelPattern.firstMatch(value);
  if (nextField == null) {
    return value;
  }
  return value.substring(0, nextField.start);
}

String? _extractNearbyName(List<String> lines, int startIndex) {
  final fragments = <String>[];
  final endIndex = (startIndex + 4).clamp(0, lines.length);

  for (var index = startIndex; index < endIndex; index++) {
    final line = lines[index];
    if (_nextFieldLabelPattern.hasMatch(line) ||
        _nonHolderNameLabelPattern.hasMatch(line)) {
      break;
    }

    final cleanedLine = _stripLabelSeparator(line);
    if (cleanedLine.trim().isEmpty) {
      continue;
    }

    fragments.add(cleanedLine);
    final candidate = _cleanNameLine(fragments.join(' '));
    if (_looksLikeBankCustomerName(candidate, allowSingleWord: true)) {
      return candidate;
    }
  }

  return null;
}

String _cleanNameLine(String line) {
  return normalizeWhitespace(
    line
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z .]'), ' ')
        .replaceAll(RegExp(r'\b(MR|MRS|MS|SHRI|SMT)\b'), ' '),
  );
}

bool _looksLikeBankCustomerName(String line, {bool allowSingleWord = false}) {
  final minimumLength = allowSingleWord ? 3 : 5;
  if (line.length < minimumLength || line.length > 40) {
    return false;
  }
  if (RegExp(r'\d').hasMatch(line)) {
    return false;
  }
  if (_bankNameStopWords.any((word) => line == word || line.contains(word))) {
    return false;
  }
  final words = line.split(' ').where((word) => word.length >= 2).toList();
  final minimumWords = allowSingleWord ? 1 : 2;
  if (words.length < minimumWords || words.length > 5) {
    return false;
  }
  return words.every((word) => RegExp(r'^[A-Z.]+$').hasMatch(word));
}
