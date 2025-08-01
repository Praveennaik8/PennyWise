import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../../../models/monthly_summary.dart';
import '../home_controller.dart';

class MonthlySummaryTab extends GetView<HomeController> {
  const MonthlySummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Obx(() {
            final monthlySummaries = controller.monthlySummaries.value ?? [];
            if (monthlySummaries.isEmpty) {
              return const Center(child: Text("No transactions available"));
            }

            return RefreshIndicator(
              onRefresh: controller.loadSmsData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 🔷 Daily Summary
                  // 🔷 Monthly Summary
                  _buildMonthlySummaryTable(monthlySummaries),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // 🔷 Monthly Summary Widget
  Widget _buildMonthlySummaryTable(List<MonthlySummary> summaries) {
    if (summaries.isEmpty) {
      return const Center(child: Text("No monthly summaries available"));
    }

    final columns = [
      const DataColumn(label: Text('Month')),
      const DataColumn(label: Text('Total Spend')),
      const DataColumn(label: Text('Total Income')),
    ];

    final rows = summaries.map((summary) {
      return DataRow(cells: [
        DataCell(Text(summary.month)),
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
