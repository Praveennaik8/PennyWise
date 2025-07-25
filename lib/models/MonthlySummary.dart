class MonthlySummary {
  final String month; // e.g. "Jul 2025"
  final double totalSpend;
  final double totalIncome;

  MonthlySummary({required this.month, required this.totalSpend, required this.totalIncome});

  @override
  String toString() {
    return 'MonthlySummary{month: $month, totalSpend: $totalSpend, totalIncome: $totalIncome}';
  }
}