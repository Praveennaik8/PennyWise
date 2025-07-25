import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/shared/constants/colors.dart';

import 'package:get/get.dart';

import '../../../models/daily_summary.dart';
import '../../../models/sms_data.dart';

class MainTab extends GetView<HomeController> {
  const MainTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Obx(() {
            // Reactive lists
            final summaries = controller.dailySummaries.value ?? [];
            final smsList = controller.smsData.value ?? [];

            if (smsList.isEmpty) {
              return Center(child: Text("No transactions available"));
            }

            return RefreshIndicator(
              onRefresh: controller.loadSmsData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Daily summary table
                  _buildDailySummaryTable(summaries),

                  SizedBox(height: 24),

                  // Transaction details table
                  _buildTransactionTable(smsList),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDailySummaryTable(List<DailySummary> summaries) {
    if (summaries.isEmpty) {
      return Center(child: Text("No daily summaries available"));
    }

    final columns = [
      DataColumn(label: Text('Date')),
      DataColumn(label: Text('Total Spend')),
      DataColumn(label: Text('Total Income')),
    ];

    final rows = summaries.map((summary) {
      return DataRow(cells: [
        DataCell(Text(_formatDate(summary.date))),
        DataCell(Text(
          "₹${summary.totalSpend.toStringAsFixed(2)}",
          style: TextStyle(color: Colors.red),
        )),
        DataCell(Text(
          "₹${summary.totalIncome.toStringAsFixed(2)}",
          style: TextStyle(color: Colors.green),
        )),
      ]);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns,
        rows: rows,
        columnSpacing: 20,
        headingRowColor: MaterialStateProperty.all(ColorConstants.lightGray.withOpacity(0.5)),
        dataRowHeight: 50,
      ),
    );
  }

  Widget _buildTransactionTable(List<SmsData> smsList) {
    final columns = [
      DataColumn(label: Text('Source')),
      DataColumn(label: Text('Amount')),
      DataColumn(label: Text('Type')),
      DataColumn(label: Text('Date')),
    ];

    final rows = smsList.map((txn) {
      return DataRow(cells: [
        DataCell(Text(txn.source)),
        DataCell(Text(txn.amount.toStringAsFixed(2))),
        DataCell(Text(
          txn.type.capitalizeFirst ?? '',
          style: TextStyle(
            color: txn.type.toLowerCase() == 'credit' ? Colors.green : Colors.red,
          ),
        )),
        DataCell(Text(_formatDate(txn.date))),
      ]);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns,
        rows: rows,
        columnSpacing: 20,
        headingRowColor: MaterialStateProperty.all(ColorConstants.lightGray.withOpacity(0.5)),
        dataRowHeight: 60,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }
}
