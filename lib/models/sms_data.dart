import 'package:penny_wise/models/transaction_type.dart';

class SmsData {
  late final String source;
  final double amount;
  final TransactionType type;
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
