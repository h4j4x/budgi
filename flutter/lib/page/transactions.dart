import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/transaction.dart';
import '../model/item_action.dart';
import '../model/period.dart';
import '../model/state/crud.dart';
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

const _periodKey = 'period';

class _TransactionsPageState extends State<TransactionsPage> {
  CrudState<Transaction> get state {
    return context.watch<CrudState<Transaction>>();
  }

  Period get period {
    final value = state.filters[_periodKey];
    return (value as Period?) ?? Period.currentMonth;
  }

  Future<List<Transaction>> load() async {
    return DI().get<TransactionService>().listTransactions(period: period);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, state.load);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CrudState<Transaction>>(
      create: (_) {
        return CrudState<Transaction>(loader: load, filters: {
          _periodKey: Period.currentMonth,
        });
      },
      child: Scaffold(
        body: body(),
        floatingActionButton: addButton(),
      ),
    );
  }

  Widget body() {
    return CustomScrollView(
      slivers: [
        toolbar(),
        TransactionList(onItemAction: onItemAction),
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
            state.setFilter(_periodKey, value);
          },
        ),
      ),
      actions: [
        IconButton(
          onPressed: state.load,
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
    state.load();
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(TransactionPage.route);
        state.load();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
