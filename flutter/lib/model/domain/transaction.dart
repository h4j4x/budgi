import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import 'category.dart';
import 'wallet.dart';

enum TransactionType {
  income(true),
  expense(false),
  walletTransfer(true);

  final bool isIncome;

  const TransactionType(this.isIncome);

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      income => l10n.transactionTypeIncome,
      expense => l10n.transactionTypeExpense,
      walletTransfer => l10n.transactionTypeWalletTransfer,
    };
  }

  Widget icon(BuildContext context) {
    return switch (this) {
      income => AppIcon.transactionIncome(context),
      expense => AppIcon.transactionExpense(context),
      walletTransfer => AppIcon.transactionTransfer(context),
    };
  }

  static TransactionType? tryParse(String? value) {
    if (value != null) {
      final theValue = value.trim();
      for (var transactionType in values) {
        if (theValue == transactionType.name) {
          return transactionType;
        }
      }
    }
    return null;
  }
}

abstract class Transaction {
  String get code;

  DateTime get dateTime;

  TransactionType get transactionType;

  Wallet get wallet;

  Category get category;

  double get amount;

  String get description;

  double get signedAmount {
    final sign = transactionType.isIncome ? 1 : -1;
    return amount * sign;
  }
}
