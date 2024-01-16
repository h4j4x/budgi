import 'package:flutter/material.dart';

import '../../model/table.dart';
import '../../util/collection.dart';

typedef RowCellBuilder<T> = Widget Function(String key, T item);

const _cellHeight = 46.0;

class AppTable<T> extends StatelessWidget {
  final Widget? header;
  final List<TableColumn> columns;
  final List<T> elements;
  final RowCellBuilder<T> rowCellBuilder;

  const AppTable({
    super.key,
    this.header,
    required this.columns,
    required this.elements,
    required this.rowCellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final widths = calculateTableWidths(columns, constraints.maxWidth - 20);
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: CustomScrollView(
          slivers: [
            if (header != null) header!,
            SliverList.separated(
              itemBuilder: (_, index) {
                if (index == 0) {
                  return _header(context, widths);
                }
                return _row(context, index - 1, widths);
              },
              separatorBuilder: (_, __) {
                return const Divider(height: 1.0);
              },
              itemCount: elements.length + 1,
            ),
          ],
        ),
      );
    });
  }

  Widget _header(BuildContext context, List<double> widths) {
    return Row(
      children: columns.mapIndexed((index, column) {
        final alignment = column.alignment ?? Alignment.centerLeft;
        return Container(
          alignment: alignment,
          width: widths[index],
          height: _cellHeight,
          decoration: _cellDecoration(context, index),
          child: Padding(
            padding: _paddingOf(alignment),
            child: Text(column.label),
          ),
        );
      }).toList(),
    );
  }

  Widget _row(BuildContext context, int index, List<double> widths) {
    final element = elements[index];
    return Row(
      children: columns.mapIndexed((index, column) {
        final alignment = column.alignment ?? Alignment.centerLeft;
        return Container(
          alignment: alignment,
          width: widths[index],
          height: _cellHeight,
          decoration: _cellDecoration(context, index),
          child: Padding(
            padding: _paddingOf(alignment),
            child: rowCellBuilder(column.key, element),
          ),
        );
      }).toList(),
    );
  }

  BoxDecoration _cellDecoration(BuildContext context, int index) {
    final borderSide = index < columns.length - 1
        ? BorderSide(
            color: Theme.of(context).disabledColor,
            width: 0.5,
          )
        : BorderSide.none;
    return BoxDecoration(
      border: Border(
        right: borderSide,
      ),
    );
  }

  EdgeInsets _paddingOf(Alignment alignment) {
    return switch (alignment) {
      Alignment.centerLeft => const EdgeInsets.only(left: 8.0),
      _ => EdgeInsets.zero,
    };
  }
}
