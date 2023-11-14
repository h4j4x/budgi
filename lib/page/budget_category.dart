import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title:
            Text('BudgetCategory ${value != null ? 'edit' : 'create'}'), // TODO
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
