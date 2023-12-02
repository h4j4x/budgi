import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/wallet.dart';
import '../model/item_action.dart';
import '../model/state/crud.dart';
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
  CrudState<Wallet> get state {
    return context.watch<CrudState<Wallet>>();
  }

  Future<List<Wallet>> load() async {
    return DI().get<WalletService>().listWallets();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, state.load);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CrudState<Wallet>>(
      create: (_) {
        return CrudState<Wallet>(loader: load);
      },
      child: Scaffold(
        body: body(),
        floatingActionButton: addButton(),
      ),
    );
  }

  Widget body() {
    return CustomScrollView(
      slivers: [
        toolbar(),
        WalletList(onItemAction: onItemAction),
      ],
    );
  }

  Widget toolbar() {
    return SliverAppBar(
      actions: [
        IconButton(
          onPressed: state.load,
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
    state.load();
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(WalletPage.route);
        state.load();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
