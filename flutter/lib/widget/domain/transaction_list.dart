import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/transaction.dart';
import '../../model/item_action.dart';
import '../../util/function.dart';
import '../../util/number.dart';
import '../../util/ui.dart';
import '../common/sliver_center.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> list;
  final bool enabled;
  final TypedContextItemAction<Transaction> onItemAction;

  const TransactionList({
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

  Widget listItem(BuildContext context, Transaction item) {
    final transactionType = item.transactionType.l10n(context);
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          item.transactionType.icon(context),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: item.transactionStatus.icon(context),
          ),
        ],
      ),
      title: Text('${item.category.name}. $transactionType ${item.amount.asMoneyString}'),
      subtitle: Text('${item.wallet.name}. ${item.description}'),
      trailing: IconButton(
        icon: AppIcon.delete(context),
        onPressed: enabled
            ? () async {
                final l10n = L10n.of(context);
                final confirm = await context.confirm(
                  title: l10n.transactionDelete,
                  description: l10n.transactionDeleteConfirm(item.description),
                );
                if (confirm && context.mounted) {
                  onItemAction(context, item, ItemAction.delete);
                }
              }
            : null,
      ),
      onTap: enabled
          ? () {
              onItemAction(context, item, ItemAction.select);
            }
          : null,
    );
  }
}
