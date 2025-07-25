import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../../../models/daily_summary.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/utils/custom_data_cells.dart';
import '../home_controller.dart';

class DailySummaryTab extends GetView<HomeController> {
  const DailySummaryTab({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Obx(() {
            final dailySummariesList = controller.dailySummaries.value ?? [];
            final dailySummaries = dailySummariesList.sublist(0, min(dailySummariesList.length, 30));

            if (dailySummaries.isEmpty) {
              return const Center(child: Text("No transactions available"));
            }

            return RefreshIndicator(
              onRefresh: controller.loadSmsData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 🔷 Daily Summary
                  _buildDailySummaryTable(dailySummaries),

                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // 🔷 Daily Summary Widget
  Widget _buildDailySummaryTable(List<DailySummary> summaries) {
    if (summaries.isEmpty) {
      return const Center(child: Text("No daily summaries available"));
    }

    final columns = [
      const DataColumn(label: Text('Date')),
      const DataColumn(label: Text('Total Spend')),
      const DataColumn(label: Text('Total Income')),
    ];

    final rows = summaries.map((summary) {
      return DataRow(cells: [
        CustomDataCells.buildWrappedDateCell(summary.date),
        DataCell(Text(
          "₹${summary.totalSpend.toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.red),
        )),
        DataCell(Text(
          "₹${summary.totalIncome.toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.green),
        )),
      ]);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          columns: columns,
          rows: rows,
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(ColorConstants.lightGray.withValues())
      ),
    );
  }
}
