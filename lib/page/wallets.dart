import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/crud_handler.dart';
import '../model/item_action.dart';
import '../model/wallet.dart';
import '../service/wallet.dart';
import '../widget/wallet_list.dart';
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
  late CrudHandler<Wallet> crudHandler;

  @override
  void initState() {
    super.initState();
    crudHandler = CrudHandler(onItemAction: onItemAction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBar(),
      body: body(),
      floatingActionButton: addButton(),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      actions: [
        IconButton(
          onPressed: crudHandler.reload,
          icon: AppIcon.reload,
        ),
      ],
    );
  }

  Widget body() {
    return CustomScrollView(
      slivers: [
        toolbar(),
        WalletList(
          crudHandler: crudHandler,
        ),
      ],
    );
  }

  Widget toolbar() {
    return SliverAppBar(
      actions: [
        IconButton(
          onPressed: crudHandler.reload,
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
    crudHandler.reload();
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(WalletPage.route);
        crudHandler.reload();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
