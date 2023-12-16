import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../app/router.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/category.dart';
import '../../model/domain/transaction.dart';
import '../../model/domain/wallet.dart';
import '../../model/sort.dart';
import '../common/sort_field.dart';
import 'category_select.dart';
import 'transaction_status_select.dart';
import 'transaction_type_select.dart';
import 'wallet_select.dart';

class TransactionFilterButton extends StatelessWidget {
  final TransactionFilter filter;
  final Function(TransactionFilter) onFiltered;
  final List<Wallet> wallets;
  final List<Category> categories;

  const TransactionFilterButton({
    super.key,
    required this.filter,
    required this.onFiltered,
    required this.wallets,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    const textScaler = TextScaler.linear(0.5);
    final items = <Widget>[
      Row(
        children: [
          AppIcon.tiny(filter.dateTimeSort.icon()),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              filter.dateTimeSort.l10n(context),
              textScaler: textScaler,
            ),
          ),
        ],
      ),
    ];
    final l10n = L10n.of(context);
    if (filter.category != null) {
      items.insert(
        0,
        Text(
          '${l10n.category}: ${filter.category!.name}',
          textScaler: textScaler,
        ),
      );
    }
    if (filter.wallet != null) {
      items.insert(
        0,
        Text(
          '${l10n.wallet}: ${filter.wallet!.name}',
          textScaler: textScaler,
        ),
      );
    }
    if (filter.transactionType != null) {
      items.insert(
        0,
        Text(
          '${l10n.transactionType}: ${filter.transactionType!.name}',
          textScaler: textScaler,
        ),
      );
    }
    if (filter.transactionStatus != null) {
      items.insert(
        0,
        Text(
          '${l10n.transactionStatus}: ${filter.transactionStatus!.name}',
          textScaler: textScaler,
        ),
      );
    }
    return TextButton.icon(
      onPressed: () {
        onFilter(context);
      },
      label: AppIcon.filter,
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: items,
      ),
    );
  }

  void onFilter(BuildContext context) async {
    final newFilter = filter.copy();
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
          walletField(context, newFilter.wallet, (value) {
            newFilter.wallet = value;
          }),
          categoryField(context, newFilter.category, (value) {
            newFilter.category = value;
          }),
          transactionTypeField(context, newFilter.transactionType, (value) {
            newFilter.transactionType = value;
          }),
          transactionStatusField(context, newFilter.transactionStatus, (value) {
            newFilter.transactionStatus = value;
          }),
          sortItem(context, newFilter.dateTimeSort, (value) {
            newFilter.dateTimeSort = value;
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
          height: 650,
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
      onFiltered(newFilter);
    }
  }

  Widget walletField(BuildContext context, Wallet? value, Function(Wallet?) onChanged) {
    return WalletSelect(
      list: wallets,
      value: value,
      onChanged: onChanged,
      hintText: L10n.of(context).transactionWalletHint,
    );
  }

  Widget categoryField(BuildContext context, Category? value, Function(Category?) onChanged) {
    return CategorySelect(
      list: categories,
      value: value ?? filter.category,
      onChanged: onChanged,
      hintText: L10n.of(context).transactionCategoryHint,
    );
  }

  Widget transactionTypeField(BuildContext context, TransactionType? value, Function(TransactionType?) onChanged) {
    return TransactionTypeSelect(
      value: value ?? filter.transactionType,
      onChanged: onChanged,
      hintText: L10n.of(context).transactionTypeHint,
    );
  }

  Widget transactionStatusField(
      BuildContext context, TransactionStatus? value, Function(TransactionStatus?) onChanged) {
    return TransactionStatusSelect(
      value: value ?? filter.transactionStatus,
      onChanged: onChanged,
      hintText: L10n.of(context).transactionStatusHint,
    );
  }

  Widget sortItem(BuildContext context, Sort value, Function(Sort) onChanged) {
    return SortField(
      mobileSize: false,
      title: L10n.of(context).sortByDateTime,
      value: value,
      onChanged: onChanged,
    );
  }
}

class TransactionFilter {
  Wallet? wallet;
  Category? category;
  TransactionType? transactionType;
  TransactionStatus? transactionStatus;
  Sort dateTimeSort;

  TransactionFilter({
    required this.wallet,
    required this.category,
    required this.transactionType,
    required this.transactionStatus,
    required this.dateTimeSort,
  });

  TransactionFilter copy() {
    return TransactionFilter(
      wallet: wallet,
      category: category,
      transactionType: transactionType,
      transactionStatus: transactionStatus,
      dateTimeSort: dateTimeSort,
    );
  }
}
