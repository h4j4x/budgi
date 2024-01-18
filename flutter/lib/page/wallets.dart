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
import '../model/table.dart';
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

const _tableIconCell = 'icon';
const _tableCodeCell = 'code';
const _tableTypeCell = 'type';
const _tableNameCell = 'name';

class _WalletsPageState extends State<WalletsPage> {
  final dataPage = DataPage.empty<Wallet>();
  final scrollController = ScrollController();
  final selectedCodes = <String>{};

  bool initialLoading = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      scrollController.addListener(scrollListener);
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

  void scrollListener() {
    if (dataPage.hasNextPage &&
        scrollController.offset >=
            scrollController.position.maxScrollExtent - 10 &&
        !scrollController.position.outOfRange) {
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
    return DomainList<Wallet, String>(
      scrollController: scrollController,
      actions: actions(),
      dataPage: dataPage,
      tableColumns: <TableColumn>[
        TableColumn(
            key: _tableIconCell,
            label: '',
            fixedWidth: 50,
            alignment: Alignment.center),
        TableColumn(key: _tableCodeCell, label: l10n.code, widthPercent: 10),
        TableColumn(
            key: _tableTypeCell, label: l10n.walletType, widthPercent: 20),
        TableColumn(key: _tableNameCell, label: l10n.walletName),
        TableColumn(
            key: 'icons',
            label: '',
            fixedWidth: 100,
            alignment: Alignment.center),
      ],
      initialLoading: initialLoading,
      loadingNextPage: loading,
      itemBuilder: listItem,
      itemCellBuilder: cellItem,
      onPageNavigation: (page) {
        loadData(FetchMode.refreshPage, page);
      },
      selectedKeys: selectedCodes,
      onKeySelect: (code, selected) {
        if (selected) {
          selectedCodes.add(code);
        } else {
          selectedCodes.remove(code);
        }
        setState(() {});
      },
      keyOf: (wallet) {
        return wallet.code;
      },
    );
  }

  List<Widget> actions() {
    final actions = <Widget>[
      IconButton(
        onPressed: !loading
            ? () {
                loadData(FetchMode.clear);
              }
            : null,
        icon: AppIcon.reload,
      ),
    ];
    if (selectedCodes.isNotEmpty) {
      actions.addAll(<Widget>[
        const VerticalDivider(),
        IconButton(
          onPressed: !loading
              ? () {
                  setState(() {
                    selectedCodes.clear();
                  });
                }
              : null,
          icon: AppIcon.clear,
        ),
        IconButton(
          onPressed: !loading
              ? () {
                  deleteSelected();
                }
              : null,
          icon: AppIcon.delete(context),
        ),
      ]);
    }
    return actions;
  }

  Widget listItem(BuildContext context, Wallet wallet, _, bool selected) {
    return ListTile(
      selected: selected,
      leading: selected ? AppIcon.selected : wallet.walletType.icon(),
      title: Text(wallet.name),
      subtitle: Row(
        children: [
          walletCodeWidget(wallet),
          Text(' ${wallet.walletType.l10n(context)}'),
        ],
      ),
      trailing: IconButton(
        icon: AppIcon.delete(context),
        onPressed: !loading
            ? () {
                deleteWallet(wallet);
              }
            : null,
      ),
      onTap: !loading
          ? () {
              editWallet(wallet);
            }
          : null,
      onLongPress: !loading
          ? () {
              if (selectedCodes.contains(wallet.code)) {
                selectedCodes.remove(wallet.code);
              } else {
                selectedCodes.add(wallet.code);
              }
              setState(() {});
            }
          : null,
    );
  }

  Widget cellItem(String key, Wallet wallet) {
    return switch (key) {
      _tableIconCell => wallet.walletType.icon(),
      _tableCodeCell => walletCodeWidget(wallet),
      _tableTypeCell => Text(wallet.walletType.l10n(context)),
      _tableNameCell => Text(wallet.name),
      _ => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: AppIcon.edit,
              onPressed: !loading
                  ? () {
                      editWallet(wallet);
                    }
                  : null,
            ),
            IconButton(
              icon: AppIcon.delete(context),
              onPressed: !loading
                  ? () {
                      deleteWallet(wallet);
                    }
                  : null,
            ),
          ],
        ),
    };
  }

  void editWallet(Wallet wallet) async {
    await context.push(WalletPage.route, extra: wallet);
    loadData(FetchMode.refreshPage, dataPage.pageNumberOfElement(wallet));
  }

  Widget walletCodeWidget(Wallet wallet) {
    return Text(
      wallet.code,
      textScaler: const TextScaler.linear(0.7),
      style: TextStyle(color: Theme.of(context).disabledColor),
    );
  }

  void deleteWallet(Wallet wallet) async {
    final l10n = L10n.of(context);
    final confirm = await context.confirm(
      title: l10n.walletDelete,
      description: l10n.walletDeleteConfirm(wallet.name),
    );
    if (confirm && context.mounted) {
      doDeleteWallet(wallet);
    }
  }

  void doDeleteWallet(Wallet wallet) async {
    try {
      await DI().get<WalletService>().deleteWallet(code: wallet.code);
    } on ValidationError<WalletError> catch (e) {
      if (e.errors.containsKey('wallet') && mounted) {
        context.showError(e.errors['wallet']!.l10n(context));
      }
    } finally {
      loadData(FetchMode.refreshPage, dataPage.pageNumberOfElement(wallet));
    }
  }

  void deleteSelected() async {
    final l10n = L10n.of(context);
    final confirm = await context.confirm(
      title: l10n.walletsDelete,
      description: l10n.walletDeleteSelectedConfirm,
    );
    if (confirm && context.mounted) {
      doDeleteSelected();
    }
  }

  void doDeleteSelected() async {
    try {
      await DI().get<WalletService>().deleteWallets(codes: selectedCodes);
    } on ValidationError<WalletError> catch (e) {
      if (e.errors.containsKey('wallet') && mounted) {
        context.showError(e.errors['wallet']!.l10n(context));
      }
    } finally {
      setState(() {
        selectedCodes.clear();
      });
      loadData(FetchMode.refreshPage);
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
    scrollController.dispose();
    super.dispose();
  }
}
