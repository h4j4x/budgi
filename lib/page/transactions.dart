import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../util/function.dart';
import '../model/item_action.dart';
import '../model/transaction.dart';
import '../service/transaction.dart';
import '../widget/entity/transaction_list.dart';
import 'transaction.dart';

class TransactionsPage extends StatefulWidget {
  static const route = '/transactions';

  const TransactionsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TransactionsPageState();
  }
}

class _TransactionsPageState extends State<TransactionsPage> {
  late CrudHandler<Transaction> crudHandler;

  @override
  void initState() {
    super.initState();
    crudHandler = CrudHandler(onItemAction: onItemAction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        TransactionList(
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
    Transaction item,
    ItemAction action,
  ) async {
    switch (action) {
      case ItemAction.select:
        {
          await context.push(TransactionPage.route, extra: item);
          break;
        }
      case ItemAction.delete:
        {
          await DI().get<TransactionService>().deleteTransaction(
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
        await context.push(TransactionPage.route);
        crudHandler.reload();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
