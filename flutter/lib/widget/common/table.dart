import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import '../../model/data_page.dart';
import '../../model/table.dart';
import '../../util/collection.dart';

typedef RowCellBuilder<T> = Widget Function(String key, T item);

const _cellHeight = 46.0;

class AppTable<T> extends StatelessWidget {
  final Widget? header;
  final List<TableColumn> columns;
  final DataPage<T> dataPage;
  final RowCellBuilder<T> rowCellBuilder;
  final bool loading;
  final Function(int) onPageNavigation;

  const AppTable({
    super.key,
    this.header,
    required this.columns,
    required this.dataPage,
    required this.rowCellBuilder,
    required this.loading,
    required this.onPageNavigation,
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
                if (index <= dataPage.pageContent.length) {
                  return _row(context, index - 1, widths);
                }
                return _footer(context);
              },
              separatorBuilder: (_, __) {
                return const Divider(height: 1.0);
              },
              itemCount: dataPage.pageContent.length + 2,
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
    final element = dataPage.pageContent[index];
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

  Widget _footer(BuildContext context) {
    final l10n = L10n.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: Text(
            l10n.paginationInfo(dataPage.pageIndexStart + 1, dataPage.pageIndexEnd, dataPage.totalElements),
            style: TextStyle(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ),
        IconButton(
            onPressed: !loading && dataPage.pageNumber > 0
                ? () {
                    onPageNavigation(0);
                  }
                : null,
            icon: AppIcon.goFirstPage),
        IconButton(
            onPressed: !loading && dataPage.pageNumber > 0
                ? () {
                    onPageNavigation(dataPage.pageNumber - 1);
                  }
                : null,
            icon: AppIcon.goPreviousPage),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: loading ? AppIcon.loading : Text((dataPage.pageNumber + 1).toString()),
        ),
        IconButton(
            onPressed: !loading && dataPage.pageNumber > 0
                ? () {
                    onPageNavigation(dataPage.pageNumber + 1);
                  }
                : null,
            icon: AppIcon.goNextPage),
        IconButton(
            onPressed: !loading && dataPage.pageNumber > 0
                ? () {
                    onPageNavigation(dataPage.totalPages - 1);
                  }
                : null,
            icon: AppIcon.goLastPage),
      ],
    );
  }
}
