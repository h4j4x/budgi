import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../widget/budget_category_amount_edit.dart';

class BudgetCategoryAmountPage extends StatelessWidget {
  static const route = '/category-amount';

  final BudgetCategoryAmount? value;
  final DateTime fromDate;
  final DateTime toDate;

  const BudgetCategoryAmountPage({
    super.key,
    this.value,
    required this.fromDate,
    required this.toDate,
  });

  BudgetCategoryAmountPage.data(BudgetCategoryAmountData data, {super.key})
      : value = data.amount,
        fromDate = data.fromDate,
        toDate = data.toDate;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final action = value != null ? l10n.editAction : l10n.createAction;
    return Scaffold(
      appBar: AppBar(
        title: Text('$action ${l10n.budgetsCategoryAmount.toLowerCase()}'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: BudgetCategoryAmountEdit(
          value: value,
          fromDate: fromDate,
          toDate: toDate,
        ),
      ),
    );
  }
}
