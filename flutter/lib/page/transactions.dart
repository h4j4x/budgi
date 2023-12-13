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
import '../widget/common/responsive.dart';
import '../widget/common/sort_field.dart';
import '../widget/domain/category_select.dart';
import '../widget/domain/transaction_list.dart';
import '../widget/domain/wallet_select.dart';
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
      body: ResponsiveWidget(mobile: body(true), desktop: body(false)),
      floatingActionButton: addButton(),
    );
  }

  Widget body(bool mobileSize) {
    return CustomScrollView(
      slivers: [
        toolbar(mobileSize),
        TransactionList(
          list: list,
          enabled: !loading,
          onItemAction: onItemAction,
        ),
      ],
    );
  }

  Widget toolbar(bool mobileSize) {
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
        if (!mobileSize)
          toolbarItem(
            child: walletField(),
          ),
        if (!mobileSize)
          toolbarItem(
            child: categoryField(),
          ),
        if (!mobileSize)
          toolbarItem(
            child: sortItem(mobileSize),
          ),
        if (mobileSize) filterButton(),
        IconButton(
          onPressed: loadList,
          icon: AppIcon.reload,
        ),
      ],
    );
  }

  Widget walletField([Wallet? value, Function(Wallet?)? onChanged]) {
    return WalletSelect(
      list: wallets,
      value: value ?? wallet,
      enabled: !loading,
      onChanged: onChanged ??
          (value) {
            wallet = value;
            loadList();
          },
      hintText: L10n.of(context).transactionWalletHint,
    );
  }

  Widget categoryField([Category? value, Function(Category?)? onChanged]) {
    return CategorySelect(
      list: categories,
      value: value ?? category,
      onChanged: onChanged ??
          (value) {
            category = value;
            loadList();
          },
      hintText: L10n.of(context).transactionCategoryHint,
      enabled: !loading,
    );
  }

  Widget sortItem(bool mobileSize, [Sort? value, Function(Sort?)? onChanged]) {
    return SortField(
        mobileSize: mobileSize,
        title: L10n.of(context).sortByDateTime,
        value: value ?? dateTimeSort,
        onChanged: !loading && list.isNotEmpty
            ? onChanged ??
                (value) {
                  dateTimeSort = value;
                  loadList();
                }
            : null);
  }

  Widget filterButton() {
    const textScaler = TextScaler.linear(0.6);
    final items = <Widget>[
      Row(
        children: [
          AppIcon.tiny(dateTimeSort.icon()),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              dateTimeSort.l10n(context),
              textScaler: textScaler,
            ),
          ),
        ],
      ),
    ];
    final l10n = L10n.of(context);
    if (category != null) {
      items.insert(
        0,
        Text(
          '${l10n.category}: ${category!.name}',
          textScaler: textScaler,
        ),
      );
    }
    if (wallet != null) {
      items.insert(
        0,
        Text(
          '${l10n.wallet}: ${wallet!.name}',
          textScaler: textScaler,
        ),
      );
    }
    return TextButton.icon(
      onPressed: onFilter,
      label: AppIcon.filter,
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: items,
      ),
    );
  }

  void onFilter() async {
    Wallet? newWallet = wallet;
    Category? newCategory = category;
    Sort newDateTimeSort = dateTimeSort;
    final value = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        final l10n = L10n.of(context);
        final items = <Widget>[
          Text(
            l10n.transactionsFilters,
            textAlign: TextAlign.center,
            textScaler: const TextScaler.linear(1.25),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          walletField(wallet, (value) {
            newWallet = value;
          }),
          categoryField(category, (value) {
            newCategory = value;
          }),
          sortItem(false, dateTimeSort, (value) {
            newDateTimeSort = value ?? Sort.desc;
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  context.pop(true);
                },
                child: Text(l10n.okAction),
              ),
              TextButton(
                onPressed: context.pop,
                child: Text(l10n.cancelAction),
              ),
            ],
          )
        ];
        return Container(
          height: 350,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: item,
              );
            }).toList(),
          ),
        );
      },
    );
    if (value ?? false) {
      setState(() {
        wallet = newWallet;
        category = newCategory;
        dateTimeSort = newDateTimeSort;
      });
    }
  }

  Widget toolbarItem({required Widget child}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.only(right: 4),
      child: child,
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
