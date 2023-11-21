import 'package:flutter/material.dart';

import '../app/info.dart';
import '../l10n/l10n.dart';

enum TransactionError {
  invalidTransactionType,
  invalidWallet,
  invalidBudgetCategory,
  invalidAmount,
  invalidDescription;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      invalidTransactionType => l10n.invalidTransactionType,
      invalidWallet => l10n.invalidTransactionWallet,
      invalidBudgetCategory => l10n.invalidBudgetCategory,
      invalidAmount => l10n.invalidTransactionAmount,
      invalidDescription =>
        l10n.invalidTransactionDescription(AppInfo.textFieldMaxLength),
    };
  }
}
