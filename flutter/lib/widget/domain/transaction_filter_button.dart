import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../app/router.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/category.dart';
import '../../model/domain/wallet.dart';
import '../../model/transaction_filter.dart';
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
    final value = await showDialog<TransactionFilter>(
      context: context,
      builder: (context) {
        return _FilterDialog(
          filter: filter,
          categories: categories,
          wallets: wallets,
        );
      },
    );
    if (value != null) {
      onFiltered(value);
    }
  }
}

class _FilterDialog extends StatefulWidget {
  final TransactionFilter filter;
  final List<Wallet> wallets;
  final List<Category> categories;

  const _FilterDialog({
    required this.filter,
    required this.wallets,
    required this.categories,
  });

  @override
  State<StatefulWidget> createState() {
    return _FilterDialogState();
  }
}

class _FilterDialogState extends State<_FilterDialog> {
  late TransactionFilter filter;

  @override
  void initState() {
    super.initState();
    filter = widget.filter.copy();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AlertDialog(
      title: Text(l10n.transactionsFilters),
      content: Column(
        children: filterItems().map((item) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: item,
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop(filter);
          },
          child: Text(l10n.okAction),
        ),
        TextButton(
          onPressed: context.pop,
          child: Text(l10n.cancelAction),
        ),
      ],
    );
  }

  List<Widget> filterItems() {
    return <Widget>[
      WalletSelect(
        list: widget.wallets,
        value: filter.wallet,
        allowClear: true,
        onChanged: (value) {
          setState(() {
            filter.wallet = value;
          });
        },
        hintText: L10n.of(context).transactionWalletHint,
      ),
      CategorySelect(
        list: widget.categories,
        value: filter.category,
        allowClear: true,
        onChanged: (value) {
          setState(() {
            filter.category = value;
          });
        },
        hintText: L10n.of(context).transactionCategoryHint,
      ),
      TransactionTypeSelect(
        value: filter.transactionType,
        allowClear: true,
        onChanged: (value) {
          setState(() {
            filter.transactionType = value;
          });
        },
        hintText: L10n.of(context).transactionTypeHint,
      ),
      TransactionStatusSelect(
        value: filter.transactionStatus,
        allowClear: true,
        onChanged: (value) {
          setState(() {
            filter.transactionStatus = value;
          });
        },
        hintText: L10n.of(context).transactionStatusHint,
      ),
      SortField(
        mobileSize: false,
        title: L10n.of(context).sortByDateTime,
        value: filter.dateTimeSort,
        onChanged: (value) {
          setState(() {
            filter.dateTimeSort = value;
          });
        },
      )
    ];
  }
}
