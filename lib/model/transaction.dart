import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'budget_category.dart';
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
}

abstract class Transaction {
  String get code;

  DateTime get dateTime;

  TransactionType get transactionType;

  Wallet get wallet;

  BudgetCategory get budgetCategory;

  double get amount;

  String get description;
}
