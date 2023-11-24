import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../l10n/l10n.dart';
import 'category.dart';
import 'wallet.dart';

enum TransactionType {
  income(true),
  incomeTransfer(true),
  expense(false),
  expenseTransfer(false);

  final bool isIncome;

  const TransactionType(this.isIncome);

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      income => l10n.transactionTypeIncome,
      incomeTransfer => l10n.transactionTypeIncomeTransfer,
      expense => l10n.transactionTypeExpense,
      expenseTransfer => l10n.transactionTypeExpenseTransfer,
    };
  }

  Widget icon(BuildContext context) {
    return switch (this) {
      income => AppIcon.transactionIncome(context),
      incomeTransfer => AppIcon.transactionIncomeTransfer(context),
      expense => AppIcon.transactionExpense(context),
      expenseTransfer => AppIcon.transactionExpenseTransfer(context),
    };
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
