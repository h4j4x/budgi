import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/category.dart';
import '../model/domain/transaction.dart';
import '../model/domain/wallet.dart';
import '../model/item_action.dart';
import '../model/period.dart';
import '../model/sort.dart';
import '../service/category.dart';
import '../service/transaction.dart';
import '../service/wallet.dart';
import '../widget/common/month_field.dart';
import '../widget/domain/transaction_filter_button.dart';
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
  List<Wallet>? wallets;
  List<Category>? categories;

  Period period = Period.currentMonth;
  Wallet? wallet;
  Category? category;
  TransactionType? transactionType;
  TransactionStatus? transactionStatus;
  Sort dateTimeSort = Sort.desc;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadList();
      loadWallets();
      loadCategories();
    });
  }

  void loadList() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    final newList = await DI().get<TransactionService>().listTransactions(
          period: period,
          wallet: wallet,
          category: category,
          transactionTypes: transactionType != null ? [transactionType!] : [],
          transactionStatuses: transactionStatus != null ? [transactionStatus!] : [],
          dateTimeSort: dateTimeSort,
        );
    list.clear();
    list.addAll(newList);
    setState(() {
      loading = false;
    });
  }

  void loadWallets() async {
    final list = await DI().get<WalletService>().listWallets();
    setState(() {
      wallets = list;
    });
  }

  void loadCategories() async {
    final list = await DI().get<CategoryService>().listCategories();
    setState(() {
      categories = list;
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
        filterButton(),
        IconButton(
          onPressed: loadList,
          icon: AppIcon.reload,
        ),
      ],
    );
  }

  Widget filterButton() {
    final filter = TransactionFilter(
      wallet: wallet,
      category: category,
      transactionType: transactionType,
      transactionStatus: transactionStatus,
      dateTimeSort: dateTimeSort,
    );
    return TransactionFilterButton(
      filter: filter,
      wallets: wallets ?? [],
      categories: categories ?? [],
      onFiltered: (newFilter) {
        setState(() {
          wallet = newFilter.wallet;
          category = newFilter.category;
          transactionType = newFilter.transactionType;
          transactionStatus = newFilter.transactionStatus;
          dateTimeSort = newFilter.dateTimeSort;
        });
      },
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
