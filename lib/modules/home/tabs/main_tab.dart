import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/constants/colors.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../models/sms_data.dart';
import '../home_controller.dart';
import '../../../shared/utils/custom_data_cells.dart';

class MainTab extends GetView<HomeController> {
  const MainTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Obx(() {
            final transactionList = controller.smsData.value ?? [];
            final smsList = transactionList.sublist(0, min(transactionList.length, Constants.MAX_TRANSACTIONS));

            if (smsList.isEmpty) {
              return const Center(child: Text("No transactions available"));
            }

            return RefreshIndicator(
              onRefresh: controller.loadSmsData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 🔷 Transaction Table
                  _buildTransactionTable(smsList),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // 🔷 Transactions Table Widget
  Widget _buildTransactionTable(List<SmsData> smsList) {
    final columns = [
      const DataColumn(label: Text('Source')),
      const DataColumn(label: Text('Amount')),
      const DataColumn(label: Text('Type')),
      const DataColumn(label: Text('Date')),
    ];

    final rows = smsList.map((txn) {
      return DataRow(cells: [
        CustomDataCells.buildWrappedCell(txn.source),
        CustomDataCells.buildWrappedCell(txn.amount.toStringAsFixed(2)),
        CustomDataCells.buildWrappedCellColoured(txn.type),
        CustomDataCells.buildWrappedDateCell(txn.date),
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
