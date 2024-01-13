import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/data_page.dart';
import '../model/domain/wallet.dart';
import '../model/fetch_mode.dart';
import '../model/item_action.dart';
import '../service/wallet.dart';
import '../widget/domain/wallet_list.dart';
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

  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _scrollController.addListener(_scrollListener);
      loadData(FetchMode.clear);
    });
  }

  void loadData(FetchMode fetchMode) async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    dataPage.apply(fetchMode);
    final newDataPage = await DI().get<WalletService>().listWallets(
          page: dataPage.pageNumber,
          pageSize: dataPage.pageSize,
        );
    dataPage.add(newDataPage);
    setState(() {
      loading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
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
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        toolbar(),
        WalletList(
          data: dataPage,
          enabled: !loading,
          onItemAction: onItemAction,
        ),
      ],
    );
  }

  Widget toolbar() {
    return SliverAppBar(
      actions: [
        IconButton(
          onPressed: () {
            loadData(FetchMode.clear);
          },
          icon: AppIcon.reload,
        ),
      ],
    );
  }

  void onItemAction(
    BuildContext context,
    Wallet item,
    ItemAction action,
  ) async {
    switch (action) {
      case ItemAction.select:
        {
          await context.push(WalletPage.route, extra: item);
          break;
        }
      case ItemAction.delete:
        {
          await DI().get<WalletService>().deleteWallet(
                code: item.code,
              );
          break;
        }
    }
    loadData(FetchMode.refreshPage);
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
