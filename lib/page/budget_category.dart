import 'package:budgi/model/budget_category.dart';
import 'package:budgi/widget/budget_category_edit.dart';
import 'package:flutter/material.dart';

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('BudgetCategory'),
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
