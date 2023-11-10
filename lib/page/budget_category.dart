import 'package:budgi/model/budget_category.dart';
import 'package:budgi/widget/budget_category_edit.dart';
import 'package:flutter/material.dart';

class BudgetCategoryPage extends StatefulWidget {
  final BudgetCategoryAmount? value;

  const BudgetCategoryPage({
    super.key,
    this.value,
  });

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoryPageState();
  }
}

class _BudgetCategoryPageState extends State<BudgetCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('BudgetCategory'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: BudgetCategoryEdit(value: widget.value),
      ),
    );
  }
}
