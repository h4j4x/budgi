import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../util/function.dart';
import '../../model/item_action.dart';
import '../../model/transaction.dart';
import '../../service/transaction.dart';
import '../../util/ui.dart';
import '../common/sliver_center.dart';

class TransactionList extends StatefulWidget {
  final CrudHandler<Transaction> crudHandler;

  const TransactionList({
    super.key,
    required this.crudHandler,
  });

  @override
  State<StatefulWidget> createState() {
    return _TransactionListState();
  }
}

class _TransactionListState extends State<TransactionList> {
  final list = <Transaction>[];

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
    final values = await DI().get<TransactionService>().listTransactions();
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

  Widget listItem(Transaction item) {
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
