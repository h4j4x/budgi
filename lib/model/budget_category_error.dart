import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

enum BudgetCategoryError {
  invalidCategoryName,
  invalidCategory,
  invalidAmount;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      invalidCategoryName => l10n.invalidBudgetCategoryName,
      invalidCategory => l10n.invalidBudgetCategory,
      invalidAmount => l10n.invalidBudgetAmount,
    };
  }
}
