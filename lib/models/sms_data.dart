class SmsData {
  final String source;
  final double amount;
  final String type; // "credit" or "debit"
  final DateTime date;

  SmsData({
    required this.source,
    required this.amount,
    required this.type,
    required this.date,
  });

  @override
  String toString() {
    return 'SmsData(source: $source, amount: $amount, type: $type, date: $date)';
  }
}
