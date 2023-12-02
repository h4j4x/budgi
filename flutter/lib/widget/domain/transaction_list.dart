import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/transaction.dart';
import '../../model/item_action.dart';
import '../../model/state/crud.dart';
import '../../util/function.dart';
import '../../util/ui.dart';
import '../common/sliver_center.dart';

class TransactionList extends StatelessWidget {
  final TypedContextItemAction<Transaction> onItemAction;

  const TransactionList({
    super.key,
    required this.onItemAction,
  });

  CrudState<Transaction> _state(BuildContext context) {
    return context.watch<CrudState<Transaction>>();
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

  Widget listItem(BuildContext context, Transaction item) {
    final transactionType = item.transactionType.l10n(context);
    final amount = item.amount.toStringAsFixed(2);
    return ListTile(
      leading: item.transactionType.icon(context),
      title: Text('${item.category.name}. $transactionType \$$amount'),
      subtitle: Text('${item.wallet.name}. ${item.description}'),
      trailing: IconButton(
        icon: AppIcon.delete(context),
        onPressed: () async {
          final l10n = L10n.of(context);
          final confirm = await context.confirm(
            title: l10n.transactionDelete,
            description: l10n.transactionDeleteConfirm(item.description),
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
