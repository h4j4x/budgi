import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import '../../model/data_page.dart';
import '../../model/table.dart';
import '../common/text_divider.dart';
import 'responsive.dart';
import 'table.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext, T, int, bool);

class DomainList<T, K> extends StatelessWidget {
  final ScrollController scrollController;
  final List<Widget> actions;
  final DataPage<T> dataPage;
  final List<TableColumn> tableColumns;
  final bool initialLoading;
  final bool loadingNextPage;
  final ItemBuilder<T> itemBuilder;
  final RowCellBuilder<T> itemCellBuilder;
  final void Function(int) onPageNavigation;
  final Set<K>? selectedKeys;
  final Function(K, bool)? onKeySelect;
  final KeyFinder<T, K>? keyOf;

  const DomainList({
    super.key,
    required this.scrollController,
    required this.actions,
    required this.dataPage,
    required this.tableColumns,
    required this.initialLoading,
    required this.loadingNextPage,
    required this.itemBuilder,
    required this.itemCellBuilder,
    required this.onPageNavigation,
    this.selectedKeys,
    this.onKeySelect,
    this.keyOf,
  });

  DomainList.list({
    super.key,
    required this.actions,
    required List<T> list,
    required this.tableColumns,
    required this.initialLoading,
    required this.loadingNextPage,
    required this.itemBuilder,
    required this.itemCellBuilder,
    this.selectedKeys,
    this.onKeySelect,
    this.keyOf,
  })  : scrollController = ScrollController(),
        dataPage = DataPage(content: list),
        onPageNavigation = ((_) {});

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
    if (dataPage.isEmpty && !loadingNextPage && !initialLoading) {
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
            if (index < dataPage.length) {
              final item = dataPage[index];
              final selected = selectedKeys != null && keyOf != null && selectedKeys!.contains(keyOf!(item));
              return itemBuilder(context, item, index, selected);
            }
            if (index == dataPage.length) {
              return TextDivider(
                color: Theme.of(context).primaryColor,
                text: L10n.of(context).pageInfo(dataPage.pageNumber + 1, dataPage.totalElements),
              );
            }
            return loadingItem(context);
          },
          separatorBuilder: (_, index) {
            final isLastPageItem = dataPage.indexIsLastPageItem(index);
            if (isLastPageItem) {
              return TextDivider(
                color: Theme.of(context).primaryColor,
                text: L10n.of(context).pageEnd(dataPage.pageNumberOfIndex(index) + 1),
              );
            }
            return const Divider();
          },
          itemCount: dataPage.length + (loadingNextPage && !initialLoading ? 2 : 1),
        ),
      ],
    );
  }

  Widget desktop(BuildContext context) {
    return AppTable<T, K>(
      header: sliverToolbar(),
      columns: tableColumns,
      dataPage: dataPage,
      rowCellBuilder: itemCellBuilder,
      loading: loadingNextPage || initialLoading,
      onPageNavigation: onPageNavigation,
      selectedKeys: selectedKeys,
      onKeySelect: onKeySelect,
      keyOf: keyOf,
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
