import 'dart:math';

import 'package:flutter/painting.dart';

class TableColumn {
  final String key;
  final String label;
  final double? widthPercent;
  final double? fixedWidth;
  final Alignment? alignment;

  TableColumn({
    String? key,
    required this.label,
    this.widthPercent,
    this.fixedWidth,
    this.alignment,
  }) : key = key ?? label;
}

List<double> calculateTableWidths(List<TableColumn> columns, double width) {
  final widths = Iterable<double>.generate(columns.length, (_) {
    return .0;
  }).toList();
  var unassigned = columns.length;
  var leftWidth = width;
  for (var index = 0; index < columns.length; index++) {
    final column = columns[index];
    if (column.fixedWidth != null) {
      widths[index] = column.fixedWidth!;
      leftWidth -= column.fixedWidth!;
      unassigned -= 1;
    } else if (column.widthPercent != null) {
      final widthPercent = column.widthPercent! > 1
          ? column.widthPercent! / 100
          : column.widthPercent!;
      widths[index] = width * widthPercent;
      leftWidth -= widths[index];
      unassigned -= 1;
    }
  }
  final avgWidth = leftWidth / unassigned;
  if (avgWidth > 0) {
    for (var index = 0; index < columns.length; index++) {
      if (leftWidth == 0) {
        break;
      }
      if (widths[index] == 0) {
        widths[index] = min(avgWidth, leftWidth);
        leftWidth -= avgWidth;
      }
    }
  }
  return widths;
}
