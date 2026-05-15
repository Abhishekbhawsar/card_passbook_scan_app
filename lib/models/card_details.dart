class CardDetails {
  const CardDetails({this.cardNumber, this.expiryDate, this.holderName});

  final String? cardNumber;
  final String? expiryDate;
  final String? holderName;

  bool get hasValidCard => cardNumber != null && cardNumber!.isNotEmpty;
}
