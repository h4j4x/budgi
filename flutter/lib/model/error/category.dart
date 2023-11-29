import 'package:flutter/material.dart';

import '../../app/config.dart';
import '../../l10n/l10n.dart';

enum CategoryError {
  invalidUser,
  invalidCategoryName,
  invalidCategory,
  invalidAmount;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      invalidUser => l10n.invalidUser,
      invalidCategoryName =>
        l10n.invalidBudgetCategoryName(AppConfig.textFieldMaxLength),
      invalidCategory => l10n.invalidBudgetCategory,
      invalidAmount => l10n.invalidBudgetAmount,
    };
  }
}
