import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import 'category.dart';
import 'wallet.dart';

abstract class Transaction {
  String get code;

  DateTime get dateTime;

  TransactionType get transactionType;

  TransactionStatus get transactionStatus;

  set transactionStatus(TransactionStatus value);

  Wallet get wallet;

  Category get category;

  double get amount;

  String get description;

  double get signedAmount {
    final sign = transactionType.isIncome ? 1 : -1;
    return amount * sign;
  }
}

enum TransactionType {
  income(true, true),
  incomeTransfer(true, false),
  expense(false, true),
  expenseTransfer(false, false),
  walletTransfer(true, true);

  final bool isIncome;
  final bool canSelect;

  const TransactionType(this.isIncome, this.canSelect);

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      income => l10n.transactionTypeIncome,
      incomeTransfer => l10n.transactionTypeIncomeTransfer,
      expense => l10n.transactionTypeExpense,
      expenseTransfer => l10n.transactionTypeExpenseTransfer,
      walletTransfer => l10n.transactionTypeWalletTransfer,
    };
  }

  Widget icon(BuildContext context) {
    return switch (this) {
      income => AppIcon.transactionIncome(context),
      incomeTransfer => AppIcon.transactionIncomeTransfer(context),
      expense => AppIcon.transactionExpense(context),
      expenseTransfer => AppIcon.transactionExpenseTransfer(context),
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

enum TransactionStatus {
  pending,
  completed;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      pending => l10n.transactionStatusPending,
      completed => l10n.transactionStatusCompleted,
    };
  }

  Widget icon(BuildContext context) {
    return switch (this) {
      pending => AppIcon.transactionPending(context),
      completed => AppIcon.transactionCompleted(context),
    };
  }

  static TransactionStatus? tryParse(String? value) {
    if (value != null) {
      final theValue = value.trim();
      for (var transactionStatus in values) {
        if (theValue == transactionStatus.name) {
          return transactionStatus;
        }
      }
    }
    return null;
  }
}
