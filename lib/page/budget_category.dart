import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../widget/budget_category_edit.dart';

class BudgetCategoryPage extends StatelessWidget {
  final BudgetCategoryAmount? value;
  final DateTime fromDate;
  final DateTime toDate;

  const BudgetCategoryPage({
    super.key,
    this.value,
    required this.fromDate,
    required this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final action = value != null ? l10n.editAction : l10n.createAction;
    return Scaffold(
      appBar: AppBar(
        title: Text('$action ${l10n.budget.toLowerCase()}'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: BudgetCategoryEdit(
          value: value,
          fromDate: fromDate,
          toDate: toDate,
        ),
      ),
    );
  }
}
