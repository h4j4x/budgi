import 'package:flutter/material.dart';

import '../../app/config.dart';
import '../../l10n/l10n.dart';

enum TransactionError {
  invalidUser,
  invalidTransactionDeferredMonths,
  invalidTransactionType,
  invalidWallet,
  invalidWalletTarget,
  invalidCategory,
  invalidAmount,
  invalidDescription;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      invalidUser => l10n.invalidUser,
      invalidTransactionDeferredMonths => l10n.invalidTransactionDeferredMonths,
      invalidTransactionType => l10n.invalidTransactionType,
      invalidWallet => l10n.invalidTransactionWallet,
      invalidWalletTarget => l10n.invalidTransactionTargetWallet,
      invalidCategory => l10n.invalidBudgetCategory,
      invalidAmount => l10n.invalidTransactionAmount,
      invalidDescription =>
        l10n.invalidTransactionDescription(AppConfig.textFieldMaxLength),
    };
  }
}
