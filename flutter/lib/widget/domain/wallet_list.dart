import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/wallet.dart';
import '../../model/item_action.dart';
import '../../model/state/crud.dart';
import '../../util/function.dart';
import '../../util/ui.dart';
import '../common/sliver_center.dart';

class WalletList extends StatelessWidget {
  final TypedContextItemAction<Wallet> onItemAction;

  const WalletList({
    super.key,
    required this.onItemAction,
  });

  CrudState<Wallet> _state(BuildContext context) {
    return context.watch<CrudState<Wallet>>();
  }

  @override
  Widget build(BuildContext context) {
    if (_state(context).loading) {
      return const SliverCenter(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return body(context);
  }

  Widget body(BuildContext context) {
    final list = _state(context).list;
    if (list.isEmpty) {
      return SliverCenter(
        child: Text(L10n.of(context).nothingHere),
      );
    }
    return SliverList.separated(
      itemBuilder: (_, index) {
        return listItem(context, list[index]);
      },
      separatorBuilder: (_, __) {
        return const Divider();
      },
      itemCount: list.length,
    );
  }

  Widget listItem(BuildContext context, Wallet item) {
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
          if (confirm && context.mounted) {
            onItemAction(context, item, ItemAction.delete);
          }
        },
      ),
      onTap: () {
        onItemAction(context, item, ItemAction.select);
      },
    );
  }
}
