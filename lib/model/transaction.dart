import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../l10n/l10n.dart';
import 'category.dart';
import 'wallet.dart';

enum TransactionType {
  income,
  incomeTransfer,
  expense,
  expenseTransfer;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      income => l10n.transactionTypeIncome,
      incomeTransfer => l10n.transactionTypeIncomeTransfer,
      expense => l10n.transactionTypeExpense,
      expenseTransfer => l10n.transactionTypeExpenseTransfer,
    };
  }

  Icon icon() {
    return switch (this) {
      income => AppIcon.incomeTransaction,
      incomeTransfer => AppIcon.incomeTransfer,
      expense => AppIcon.expenseTransaction,
      expenseTransfer => AppIcon.expenseTransfer,
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
}
