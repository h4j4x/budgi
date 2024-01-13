import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import '../../model/data_page.dart';
import '../../model/domain/wallet.dart';
import '../../model/item_action.dart';
import '../../util/function.dart';
import '../../util/ui.dart';
import '../common/sliver_center.dart';
import '../common/text_divider.dart';

class WalletList extends StatelessWidget {
  final DataPage<Wallet> data;
  final bool enabled;
  final bool loadingNextPage;
  final TypedContextItemAction<Wallet> onItemAction;

  const WalletList({
    super.key,
    required this.data,
    required this.enabled,
    required this.loadingNextPage,
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
    if (data.isEmpty) {
      return SliverCenter(
        child: Text(L10n.of(context).nothingHere),
      );
    }
    return SliverList.separated(
      itemBuilder: (_, index) {
        if (index < data.length) {
          return listItem(context, data[index]);
        }
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
      },
      separatorBuilder: (_, index) {
        final isLastPageItem = data.indexIsLastPageItem(index);
        if (isLastPageItem) {
          return TextDivider(
            color: Theme.of(context).primaryColor,
            text: L10n.of(context).pageEnd(data.pageNumberOfIndex(index)),
          );
        }
        return const Divider();
      },
      itemCount: data.length + (loadingNextPage ? 1 : 0),
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
