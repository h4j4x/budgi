import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/data_page.dart';
import '../model/domain/wallet.dart';
import '../model/error/validation.dart';
import '../model/error/wallet.dart';
import '../model/fetch_mode.dart';
import '../model/item_action.dart';
import '../service/wallet.dart';
import '../util/ui.dart';
import '../widget/common/domain_list.dart';
import 'wallet.dart';

class WalletsPage extends StatefulWidget {
  static const route = '/wallets';

  const WalletsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletsPageState();
  }
}

class _WalletsPageState extends State<WalletsPage> {
  final dataPage = DataPage.empty<Wallet>();
  final _scrollController = ScrollController();

  bool initialLoading = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _scrollController.addListener(_scrollListener);
      loadData(FetchMode.clear);
    });
  }

  void loadData(FetchMode fetchMode, [int? pageNumber]) async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    dataPage.apply(fetchMode, pageNumber);
    final newDataPage = await DI().get<WalletService>().listWallets(
          page: dataPage.nextPageNumber,
          pageSize: dataPage.pageSize,
        );
    dataPage.add(newDataPage);
    setState(() {
      initialLoading = false;
      loading = false;
    });
  }

  void _scrollListener() {
    if (dataPage.hasNextPage &&
        _scrollController.offset >= _scrollController.position.maxScrollExtent - 10 &&
        !_scrollController.position.outOfRange) {
      loadData(FetchMode.nextPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      floatingActionButton: addButton(),
    );
  }

  Widget body() {
    final l10n = L10n.of(context);
    return DomainList<Wallet>(
      scrollController: _scrollController,
      actions: actions(),
      data: dataPage,
      dataColumns: <DataColumn>[
        const DataColumn(label: Text('')),
        DataColumn(label: Text(l10n.code)),
        DataColumn(label: Text(l10n.walletType)),
        DataColumn(label: Text(l10n.walletName)),
        const DataColumn(label: Text('')),
      ],
      initialLoading: initialLoading,
      loadingNextPage: loading,
      itemBuilder: listItem,
      itemRowBuilder: rowItem,
      onItemAction: onItemAction,
    );
  }

  List<Widget> actions() {
    return <Widget>[
      IconButton(
        onPressed: () {
          loadData(FetchMode.clear);
        },
        icon: AppIcon.reload,
      ),
    ];
  }

  Widget listItem(BuildContext context, Wallet item, _) {
    return ListTile(
      leading: item.walletType.icon(),
      title: Text(item.name),
      subtitle: Row(
        children: [
          itemCodeWidget(item),
          Text(' ${item.walletType.l10n(context)}'),
        ],
      ),
      trailing: IconButton(
        icon: AppIcon.delete(context),
        onPressed: !loading
            ? () async {
                final l10n = L10n.of(context);
                final confirm = await context.confirm(
                  title: l10n.walletDelete,
                  description: l10n.walletDeleteConfirm(item.name),
                );
                if (confirm && context.mounted) {
                  onItemAction(context, item, ItemAction.delete);
                }
              }
            : null,
      ),
      onTap: !loading
          ? () {
              onItemAction(context, item, ItemAction.select);
            }
          : null,
    );
  }

  DataRow rowItem(int index) {
    final item = dataPage[index];
    return DataRow(cells: [
      DataCell(item.walletType.icon()),
      DataCell(itemCodeWidget(item)),
      DataCell(Text(item.walletType.l10n(context))),
      DataCell(Text(item.name)),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: AppIcon.edit, onPressed: () {}),
          IconButton(icon: AppIcon.delete(context), onPressed: () {}),
        ],
      )), //TODO
    ]);
  }

  Widget itemCodeWidget(Wallet item) {
    return Text(
      item.code,
      textScaler: const TextScaler.linear(0.7),
      style: TextStyle(color: Theme.of(context).disabledColor),
    );
  }

  void onItemAction(
    BuildContext context,
    Wallet item,
    ItemAction action,
  ) async {
    try {
      switch (action) {
        case ItemAction.select:
          {
            await context.push(WalletPage.route, extra: item);
            break;
          }
        case ItemAction.delete:
          {
            await DI().get<WalletService>().deleteWallet(code: item.code);
            break;
          }
      }
    } on ValidationError<WalletError> catch (e) {
      if (e.errors.containsKey('wallet') && mounted) {
        context.showError(e.errors['wallet']!.l10n(context));
      }
    } finally {
      loadData(FetchMode.refreshPage, dataPage.pageNumberOfElement(item));
    }
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(WalletPage.route);
        loadData(FetchMode.refreshPage);
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
