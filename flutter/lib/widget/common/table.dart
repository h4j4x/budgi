import 'package:flutter/material.dart';

import '../../model/table.dart';
import '../../util/collection.dart';

typedef RowCellBuilder<T> = Widget Function(String key, T item);

class AppTable<T> extends StatelessWidget {
  final List<TableColumn> columns;
  final List<T> elements;
  final RowCellBuilder rowCellBuilder;

  const AppTable({
    super.key,
    required this.columns,
    required this.elements,
    required this.rowCellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final widths = calculateTableWidths(columns, constraints.maxWidth);
      return CustomScrollView(
        slivers: [
          SliverList.separated(
            itemBuilder: (_, index) {
              if (index == 0) {
                return _header(widths);
              }
              return _row(index - 1, widths);
            },
            separatorBuilder: (_, __) {
              return const Divider();
            },
            itemCount: elements.length + 1,
          ),
        ],
      );
    });
  }

  Widget _header(List<double> widths) {
    return Row(
      children: columns.mapIndexed((index, column) {
        return SizedBox(width: widths[index], child: Text(column.label));
      }).toList(),
    );
  }

  Widget _row(int index, List<double> widths) {
    final element = elements[index];
    return Row(
      children: columns.mapIndexed((index, column) {
        return SizedBox(width: widths[index], child: rowCellBuilder(column.key, element));
      }).toList(),
    );
  }
}
