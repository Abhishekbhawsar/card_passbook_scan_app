class BankDetails {
  const BankDetails({
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
  });

  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;

  bool get hasAnyValue =>
      accountHolderName != null || accountNumber != null || ifscCode != null;
}
