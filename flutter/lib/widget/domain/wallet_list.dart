import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/wallet.dart';
import '../../model/item_action.dart';
import '../../util/function.dart';
import '../../util/ui.dart';
import '../common/sliver_center.dart';

class WalletList extends StatelessWidget {
  final List<Wallet> list;
  final bool enabled;
  final TypedContextItemAction<Wallet> onItemAction;

  const WalletList({
    super.key,
    required this.list,
    required this.enabled,
    required this.onItemAction,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const SliverCenter(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return body(context);
  }

  Widget body(BuildContext context) {
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
