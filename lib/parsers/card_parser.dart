import '../models/card_details.dart';
import '../utils/text_cleanup.dart';

const Set<String> _cardNameStopWords = {
  'VISA',
  'VALID',
  'VALID THRU',
  'VALID FROM',
  'MASTERCARD',
  'MASTER CARD',
  'CARD',
  'BANK',
  'DEBIT',
  'CREDIT',
  'PLATINUM',
  'RUPAY',
  'AMEX',
};

CardDetails parseCard(String rawText) {
  final lines = normalizedLines(rawText);
  final normalizedForNumbers = normalizeOcrDigits(rawText);
  final cardNumber = _extractValidCardNumber(normalizedForNumbers);
  final expiryDate = _extractExpiryDate(normalizedForNumbers);
  final holderName = _extractCardHolderName(lines);

  return CardDetails(
    cardNumber: cardNumber,
    expiryDate: expiryDate,
    holderName: holderName,
  );
}

bool isValidCard(String cardNumber) {
  final digits = normalizeOcrDigits(
    cardNumber,
  ).replaceAll(RegExp(r'[\s-]'), '');
  if (!RegExp(r'^\d{13,19}$').hasMatch(digits)) {
    return false;
  }

  var sum = 0;
  var shouldDouble = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var digit = int.parse(digits[i]);
    if (shouldDouble) {
      digit *= 2;
      if (digit > 9) {
        digit -= 9;
      }
    }
    sum += digit;
    shouldDouble = !shouldDouble;
  }

  return sum % 10 == 0;
}

String maskCardNumber(String cardNumber) {
  final digits = normalizeOcrDigits(
    cardNumber,
  ).replaceAll(RegExp(r'[\s-]'), '');
  if (digits.length < 4) {
    return 'XXXX';
  }
  return 'XXXX XXXX XXXX ${digits.substring(digits.length - 4)}';
}

String? _extractValidCardNumber(String rawText) {
  final candidates = <String>{};
  // Keep separators optional so OCR can return grouped, dashed, or compact PANs.
  final separatedPattern = RegExp(r'(?<!\d)(?:\d[ -]?){13,19}(?!\d)');

  for (final match in separatedPattern.allMatches(rawText)) {
    final candidate = match.group(0);
    if (candidate != null) {
      candidates.add(candidate);
    }
  }

  for (final candidate in candidates) {
    final digits = candidate.replaceAll(RegExp(r'[\s-]'), '');
    if (isValidCard(digits)) {
      return digits;
    }
  }

  return null;
}

String? _extractExpiryDate(String rawText) {
  final separatedExpiry = RegExp(
    r'(?<!\d)(0[1-9]|1[0-2])\s*[/-]\s*(\d{2})(?!\d)',
  );
  for (final match in separatedExpiry.allMatches(rawText)) {
    final month = match.group(1)!;
    final year = match.group(2)!;
    if (_isPlausibleExpiry(month, year)) {
      return '$month/$year';
    }
  }

  final compactExpiry = RegExp(r'(?<!\d)(0[1-9]|1[0-2])(\d{2})(?!\d)');
  for (final match in compactExpiry.allMatches(rawText)) {
    final month = match.group(1)!;
    final year = match.group(2)!;
    if (_isPlausibleExpiry(month, year)) {
      return '$month/$year';
    }
  }

  return null;
}

bool _isPlausibleExpiry(String month, String year) {
  final parsedMonth = int.tryParse(month);
  final parsedYear = int.tryParse(year);
  if (parsedMonth == null || parsedYear == null) {
    return false;
  }
  return parsedMonth >= 1 &&
      parsedMonth <= 12 &&
      parsedYear >= 20 &&
      parsedYear <= 40;
}

String? _extractCardHolderName(List<String> lines) {
  for (final line in lines.reversed) {
    final cleaned = normalizeWhitespace(
      line
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z .]'), ' ')
          .replaceAll(RegExp(r'\b(MR|MRS|MS)\b'), ' '),
    );
    if (cleaned.length < 5 || cleaned.length > 32) {
      continue;
    }
    if (!_looksLikeName(cleaned, _cardNameStopWords)) {
      continue;
    }
    return cleaned;
  }

  return null;
}

bool _looksLikeName(String line, Set<String> stopWords) {
  if (stopWords.any(
    (word) =>
        line == word ||
        line.contains(' $word ') ||
        line.startsWith('$word ') ||
        line.endsWith(' $word'),
  )) {
    return false;
  }
  final words = line.split(' ').where((word) => word.length >= 2).toList();
  if (words.length < 2 || words.length > 4) {
    return false;
  }
  return words.every((word) => RegExp(r'^[A-Z.]+$').hasMatch(word));
}
