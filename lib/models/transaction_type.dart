enum TransactionType {
  debit,
  credit,
  unknown; // Optional: for cases where type can't be determined

  // Keywords
  static final _debitKeywords = [
    'debited', 'withdrawn', 'spent', 'purchase', 'paid'
  ];
  static final _creditKeywords = [
    'credited', 'received', 'earned', 'refund', 'deposited'
  ];

  /// Converts a string to a TransactionType.
  /// Returns TransactionType.unknown if the string does not match.
  static TransactionType? getTransactionType(String body) {
    // Identify type
    return _debitKeywords.any(body.contains)
        ? TransactionType.debit
        : _creditKeywords.any(body.contains)
        ? TransactionType.credit
        : null;
  }

  /// Provides a user-friendly string representation.
  String get displayName {
    switch (this) {
      case TransactionType.debit:
        return 'Debit';
      case TransactionType.credit:
        return 'Credit';
      case TransactionType.unknown:
        return 'Unknown';
    }
  }
}