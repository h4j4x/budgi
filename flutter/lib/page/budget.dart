import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../model/domain/category_amount.dart';
import '../model/period.dart';
import '../widget/domain/budget_edit.dart';

class BudgetPage extends StatelessWidget {
  static const route = '/category-amount';

  final Budget? value;
  final Period period;

  const BudgetPage({
    super.key,
    this.value,
    required this.period,
  });

  BudgetPage.data(BudgetData data, {super.key})
      : value = data.budget,
        period = data;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final action = value != null ? l10n.editAction : l10n.createAction;
    return Scaffold(
      appBar: AppBar(
        title: Text('$action ${l10n.budgetAmount.toLowerCase()}'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: BudgetEdit(
          value: value,
          period: period,
        ),
      ),
    );
  }
}
