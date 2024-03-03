import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

enum BudgetError {
  invalidUser,
  invalidCategory,
  invalidPeriod,
  invalidAmount;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      invalidUser => l10n.invalidUser,
      invalidCategory => l10n.invalidCategory,
      invalidPeriod => l10n.invalidBudgetPeriod,
      invalidAmount => l10n.invalidBudgetAmount,
    };
  }
}
