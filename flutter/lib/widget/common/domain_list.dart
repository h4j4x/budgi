import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import '../../model/data_page.dart';
import '../../model/table.dart';
import '../../util/function.dart';
import '../common/text_divider.dart';
import 'responsive.dart';
import 'table.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext, T item, int index);

class DomainList<T> extends StatelessWidget {
  final ScrollController scrollController;
  final List<Widget> actions;
  final DataPage<T> data;
  final List<TableColumn> tableColumns;
  final bool initialLoading;
  final bool loadingNextPage;
  final ItemBuilder<T> itemBuilder;
  final RowCellBuilder<T> itemCellBuilder;
  final TypedContextItemAction<T> onItemAction;

  const DomainList({
    super.key,
    required this.scrollController,
    required this.actions,
    required this.data,
    required this.tableColumns,
    required this.initialLoading,
    required this.loadingNextPage,
    required this.itemBuilder,
    required this.itemCellBuilder,
    required this.onItemAction,
  });

  @override
  Widget build(BuildContext context) {
    if (initialLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return body(context);
  }

  Widget body(BuildContext context) {
    if (data.isEmpty && !loadingNextPage && !initialLoading) {
      return Center(
        child: Text(L10n.of(context).nothingHere),
      );
    }
    return ResponsiveWidget(mobile: mobile(context), desktop: desktop(context));
  }

  Widget mobile(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        sliverToolbar(),
        SliverList.separated(
          itemBuilder: (_, index) {
            if (index < data.length) {
              return itemBuilder(context, data[index], index);
            }
            if (index == data.length) {
              return TextDivider(
                color: Theme.of(context).primaryColor,
                text: L10n.of(context).pageInfo(data.pageNumber + 1, data.totalElements),
              );
            }
            return loadingItem(context);
          },
          separatorBuilder: (_, index) {
            final isLastPageItem = data.indexIsLastPageItem(index);
            if (isLastPageItem) {
              return TextDivider(
                color: Theme.of(context).primaryColor,
                text: L10n.of(context).pageEnd(data.pageNumberOfIndex(index) + 1),
              );
            }
            return const Divider();
          },
          itemCount: data.length + (loadingNextPage && !initialLoading ? 2 : 1),
        ),
      ],
    );
  }

  Widget desktop(BuildContext context) {
    return AppTable<T>(
      header: sliverToolbar(),
      columns: tableColumns,
      elements: data.pageContent,
      rowCellBuilder: itemCellBuilder,
    );
  }

  Widget loadingItem(BuildContext context) {
    return ListTile(
      leading: AppIcon.loadingOfSize(18),
      title: Text(
        L10n.of(context).loadingNextPage,
        textScaler: const TextScaler.linear(0.75),
        style: TextStyle(
          color: Theme.of(context).disabledColor,
        ),
      ),
    );
  }

  Widget sliverToolbar() {
    final items = <Widget>[];
    if (loadingNextPage || initialLoading) {
      items.add(Padding(padding: const EdgeInsets.only(right: 8.0), child: AppIcon.loadingOfSize(14.0)));
    }
    if (actions.isNotEmpty) {
      items.addAll(actions);
    }
    if (items.isNotEmpty) {
      return SliverAppBar(actions: items, elevation: .0, backgroundColor: Colors.transparent);
    }
    return Container();
  }
}
