// Add this class for daily summary
import 'package:flutter_getx_boilerplate/models/sms_data.dart';

class DailySummary {
  final DateTime date;
  final double totalSpend;
  final double totalIncome;

  DailySummary({
    required this.date,
    required this.totalSpend,
    required this.totalIncome,
  });

  @override
  String toString() {
    return 'DailySummary{date: $date, totalSpend: $totalSpend, totalIncome: $totalIncome}';
  }
}

extension SmsSummaryExtension on List<SmsData> {
  List<DailySummary> groupByDate() {
    final Map<String, List<SmsData>> grouped = {};

    for (var sms in this) {
      final key = DateTime(sms.date.year, sms.date.month, sms.date.day).toIso8601String();
      grouped.putIfAbsent(key, () => []).add(sms);
    }

    return grouped.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      final spend = entry.value
          .where((sms) => sms.type == 'debit')
          .fold(0.0, (sum, sms) => sum + sms.amount);
      final income = entry.value
          .where((sms) => sms.type == 'credit')
          .fold(0.0, (sum, sms) => sum + sms.amount);

      return DailySummary(
        date: date,
        totalSpend: spend,
        totalIncome: income,
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }
}
