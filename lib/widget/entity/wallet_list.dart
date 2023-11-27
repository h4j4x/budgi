import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../util/function.dart';
import '../../model/item_action.dart';
import '../../model/wallet.dart';
import '../../service/wallet.dart';
import '../../util/ui.dart';
import '../common/sliver_center.dart';

class WalletList extends StatefulWidget {
  final CrudHandler<Wallet> crudHandler;

  const WalletList({
    super.key,
    required this.crudHandler,
  });

  @override
  State<StatefulWidget> createState() {
    return _WalletListState();
  }
}

class _WalletListState extends State<WalletList> {
  final list = <Wallet>[];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    widget.crudHandler.reload = () {
      Future.delayed(Duration.zero, () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loadList();
        });
      });
    };
    Future.delayed(Duration.zero, loadList);
  }

  void loadList() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    final values = await DI().get<WalletService>().listWallets();
    list.clear();
    list.addAll(values);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SliverCenter(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return body();
  }

  Widget body() {
    if (list.isEmpty) {
      return SliverCenter(
        child: Text(L10n.of(context).nothingHere),
      );
    }
    return SliverList.separated(
      itemBuilder: (_, index) {
        return listItem(list[index]);
      },
      separatorBuilder: (_, __) {
        return const Divider();
      },
      itemCount: list.length,
    );
  }

  Widget listItem(Wallet item) {
    return ListTile(
      leading: item.walletType.icon(),
      title: Text(item.name),
      subtitle: Text(item.walletType.l10n(context)),
      trailing: IconButton(
        icon: AppIcon.delete(context),
        onPressed: () async {
          final l10n = L10n.of(context);
          final confirm = await context.confirm(
            title: l10n.walletDelete,
            description: l10n.walletDeleteConfirm(item.name),
          );
          if (confirm && mounted) {
            widget.crudHandler.onItemAction(context, item, ItemAction.delete);
          }
        },
      ),
      onTap: () {
        widget.crudHandler.onItemAction(context, item, ItemAction.select);
      },
    );
  }
}
