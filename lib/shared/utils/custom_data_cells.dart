import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDataCells {

  static DataCell buildWrappedCell(String text, {double maxWidth = 100}) {
    return DataCell(
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Text(
          text,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  static DataCell buildWrappedCellColoured(String text, {double maxWidth = 100}) {
    return DataCell(
        ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              text.capitalizeFirst ?? '',
              style: TextStyle(
                color: text.toLowerCase() == 'credit' ? Colors.green : Colors.red,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            )
        )
    );
  }

  static DataCell buildWrappedDateCell(DateTime date, {double maxWidth = 120}) {
    return DataCell(
        ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              _formatDate(date),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            )
        )
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }
}