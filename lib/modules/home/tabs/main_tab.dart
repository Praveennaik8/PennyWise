import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/daily_summary.dart';
import '../../../models/sms_data.dart';
import '../../../shared/utils/custom_data_cells.dart';
import '../home_controller.dart';

class MainTab extends StatefulWidget {
  const MainTab({super.key});

  @override
  State<MainTab> createState() => _PennywiseSummaryPageState();
}

class _PennywiseSummaryPageState extends State<MainTab> with TickerProviderStateMixin {
  bool showAllDays = false;
  late ScrollController _scrollController;
  bool showHideButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final atTop = _scrollController.position.pixels <= 20;
      if (showHideButton != atTop) {
        setState(() {
          showHideButton = atTop;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: GetX<HomeController>(
          builder: (controller) {
            final dailySummariesList = controller.dailySummaries.value ?? [];
            final allTransactions = controller.smsData.value ?? [];

            if (dailySummariesList.isEmpty) {
              return const Center(child: Text("No data available"));
            }

            final today = DateTime.now();
            final todaySummary = dailySummariesList.firstWhereOrNull((
                summary) =>
            summary.date.year == today.year &&
                summary.date.month == today.month &&
                summary.date.day == today.day);

            final otherSummaries = dailySummariesList
                .where((s) =>
            !(s.date.year == today.year &&
                s.date.month == today.month &&
                s.date.day == today.day))
                .toList();

            final limitedOthers = otherSummaries.length > 30
                ? otherSummaries.sublist(0, 30)
                : otherSummaries;

            final List<DailySummary> listToShow = [];
            if (todaySummary != null) listToShow.add(todaySummary);
            if (showAllDays) listToShow.addAll(limitedOthers);

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: controller.loadSmsData,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: listToShow.length + (showAllDays ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (!showAllDays && index == 0) {
                        // Message card with Flexible text to prevent overflow
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: Colors.blueGrey.shade50,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                          Icons.pie_chart_outline, size: 28,
                                          color: Colors.blueGrey),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          "Today's summary",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey.shade800,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Quick view of your daily expenses and incomes to keep you on track.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey.shade600,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final summaryIndex = !showAllDays ? index - 1 : index;
                      final summary = listToShow[summaryIndex];
                      final isToday = (!showAllDays && summaryIndex == 0
                          && todaySummary != null);

                      return AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: _buildExpandableSummary(summary, allTransactions,
                            initiallyExpanded: isToday),
                      );
                    },
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: showHideButton ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () =>
                            setState(() => showAllDays = !showAllDays),
                        child: Text(
                          showAllDays
                              ? "Hide All Summaries"
                              : "View All Summaries",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandableSummary(DailySummary summary,
      List<SmsData> allTransactions,
      {bool initiallyExpanded = false}) {
    final dayTransactions = allTransactions.where((txn) {
      return txn.date.year == summary.date.year &&
          txn.date.month == summary.date.month &&
          txn.date.day == summary.date.day;
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        iconColor: Colors.blueGrey.shade600,
        collapsedIconColor: Colors.blueGrey.shade600,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEE, dd MMM yyyy').format(summary.date),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.blueGrey.shade800,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Spend: ₹${summary.totalSpend.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.redAccent.shade200,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Income: ₹${summary.totalIncome.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          SizedBox(
            height: 200,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery
                  .of(context)
                  .size
                  .width),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildTransactionTable(dayTransactions),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTable(List<SmsData> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text("No transactions for this day"),
        ),
      );
    }

    final columns = [
      const DataColumn(label: Text('Source')),
      const DataColumn(label: Text('Amount')),
      const DataColumn(label: Text('Type')),
      const DataColumn(label: Text('Time')),
    ];

    final rows = transactions
        .asMap()
        .entries
        .map((entry) {
      final idx = entry.key;
      final txn = entry.value;
      final isDebit = txn.type.toLowerCase() == "debit";

      return DataRow(
        color: MaterialStateProperty.all(
          idx % 2 == 0 ? Colors.grey.withOpacity(0.05) : Colors.transparent,
        ),
        cells: [
          CustomDataCells.buildWrappedCell(txn.source),
          DataCell(
            Text(
              "₹${txn.amount.toStringAsFixed(2)}",
              style: TextStyle(
                color: isDebit ? Colors.redAccent.shade200 : Colors.green
                    .shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          CustomDataCells.buildWrappedCellColoured(txn.type),
          DataCell(Text(DateFormat('hh:mm a').format(txn.date))),
        ],
      );
    }).toList();

    return DataTable(
      columns: columns,
      rows: rows,
      columnSpacing: 20,
      headingRowColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.08)),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.blueGrey.shade800,
      ),
    );
  }
}
