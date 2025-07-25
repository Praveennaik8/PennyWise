import 'package:flutter_getx_boilerplate/models/sms_data.dart';

class MonthlySummary {
  final String month; // e.g. "Jul 2025"
  final double totalSpend;
  final double totalIncome;

  MonthlySummary(
      {required this.month, required this.totalSpend, required this.totalIncome});

  @override
  String toString() {
    return 'MonthlySummary{month: $month, totalSpend: $totalSpend, totalIncome: $totalIncome}';
  }
}

extension SmsSummaryExtension on List<SmsData> {
  /// Groups SMS data into monthly summaries
  List<MonthlySummary> groupByMonth() {
    if (isEmpty) return [];

    final Map<String, List<SmsData>> groupedByMonth = {};

    for (var sms in this) {
      final key = _monthKey(sms.date); // "Jul 2025"
      groupedByMonth.putIfAbsent(key, () => []).add(sms);
    }

    return groupedByMonth.entries.map((entry) {
      final transactions = entry.value;

      final totalIncome = transactions
          .where((t) => t.type.toLowerCase() == 'credit')
          .fold(0.0, (sum, t) => sum + t.amount);

      final totalSpend = transactions
          .where((t) => t.type.toLowerCase() == 'debit')
          .fold(0.0, (sum, t) => sum + t.amount);

      return MonthlySummary(
        month: entry.key,
        totalIncome: totalIncome,
        totalSpend: totalSpend,
      );
    }).toList();
  }
}


String _monthKey(DateTime date) {
  return "${_monthName(date.month)} ${date.year}";
}

String _monthName(int month) {
  const names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return names[month - 1];
}