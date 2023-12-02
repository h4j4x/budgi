import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/wallet.dart';
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
  final list = <Wallet>[];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, loadList);
  }

  void loadList() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    final newList = await DI().get<WalletService>().listWallets();
    list.clear();
    list.addAll(newList);
    setState(() {
      loading = false;
    });
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
      slivers: [
        toolbar(),
        WalletList(
          list: list,
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
          onPressed: loadList,
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
    loadList();
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(WalletPage.route);
        loadList();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
