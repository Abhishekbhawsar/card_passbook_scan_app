String normalizeWhitespace(String value) {
  return value.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
}

String normalizeOcrDigits(String value) {
  return value
      .replaceAll(RegExp('[oO]'), '0')
      .replaceAll(RegExp('[iIlL|]'), '1')
      .replaceAll(RegExp('[sS]'), '5');
}

List<String> normalizedLines(String rawText) {
  return rawText
      .split(RegExp(r'\r?\n'))
      .map(normalizeWhitespace)
      .where((line) => line.isNotEmpty)
      .toList();
}
