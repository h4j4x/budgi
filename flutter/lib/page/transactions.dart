import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/transaction.dart';
import '../model/item_action.dart';
import '../model/period.dart';
import '../service/transaction.dart';
import '../widget/common/month_field.dart';
import '../widget/domain/transaction_list.dart';
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
  final list = <Transaction>[];

  bool loading = false;
  Period period = Period.currentMonth;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, loadList);
  }

  void loadList() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    final newList =
        await DI().get<TransactionService>().listTransactions(period: period);
    list.clear();
    list.addAll(newList);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      floatingActionButton: addButton(),
    );
  }

  Widget body() {
    return CustomScrollView(
      slivers: [
        toolbar(),
        TransactionList(
          list: list,
          enabled: !loading,
          onItemAction: onItemAction,
        ),
      ],
    );
  }

  Widget toolbar() {
    return SliverAppBar(
      toolbarHeight: kToolbarHeight + 16,
      title: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: MonthFieldWidget(
          period: period,
          onChanged: (value) {
            setState(() {
              period = value;
            });
            loadList();
          },
        ),
      ),
      actions: [
        IconButton(
          onPressed: loadList,
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
    loadList();
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(TransactionPage.route);
        loadList();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
