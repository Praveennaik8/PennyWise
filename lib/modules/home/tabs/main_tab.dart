import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/models/response/users_response.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/shared/constants/colors.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/sms_data.dart';

class MainTab extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Obx(
                () => RefreshIndicator(
              child: _buildTableView(),
              onRefresh: () => controller.loadSmsData(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableView() {
    if (smsData == null || smsData!.isEmpty) {
      return Center(child: Text("No transactions available"));
    }

    List<DataColumn> columns = [
      DataColumn(label: Text('Source')),
      DataColumn(label: Text('Amount')),
      DataColumn(label: Text('Type')),
      DataColumn(label: Text('Date')),
    ];

    List<DataRow> rows = smsData!.map((txn) {
      return DataRow(cells: [
        DataCell(Text(txn.source)),
        DataCell(Text(txn.amount.toStringAsFixed(2))),
        DataCell(Text(
          txn.type.capitalizeFirst ?? '',
          style: TextStyle(
            color: txn.type.toLowerCase() == 'credit'
                ? Colors.green
                : Colors.red,
          ),
        )),
        DataCell(Text(
          _formatDate(txn.date),
        )),
      ]);
    }).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [ SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          rows: rows,
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(
            ColorConstants.lightGray.withOpacity(0.5),
          ),
          dataRowHeight: 60,
        ),
      ),
    )]);
  }

  List<SmsData>? get smsData {
    return controller.smsData.value ?? [];
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  // Widget _buildGridView() {
  //   return MasonryGridView.count(
  //     crossAxisCount: 4,
  //     itemCount: data!.length,
  //     itemBuilder: (BuildContext context, int index) => new Container(
  //       color: ColorConstants.lightGray,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           Text('${data![index].lastName} ${data![index].firstName}'),
  //           CachedNetworkImage(
  //             fit: BoxFit.fill,
  //             imageUrl: data![index].avatar ??
  //                 'https://reqres.in/img/faces/1-image.jpg',
  //             placeholder: (context, url) => Image(
  //               image: AssetImage('assets/images/icon_success.png'),
  //             ),
  //             errorWidget: (context, url, error) => Icon(Icons.error),
  //           ),
  //           Text('${data![index].email}'),
  //         ],
  //       ),
  //     ),
  //   );
  // }




  // List<Datum>? get data {
  //   return controller.users.value == null ? [] : controller.users.value!.data;
  // }
}
