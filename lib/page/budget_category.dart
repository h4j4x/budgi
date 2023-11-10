import 'package:flutter/material.dart';

import '../widget/budget_category_list.dart';

class BudgetCategoryPage extends StatefulWidget {
  const BudgetCategoryPage({super.key});

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
        title: const Text('BudgetCategoryPage'), // TODO
      ),
      body: const BudgetCategoryList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add', // TODO
        child: const Icon(Icons.add),
      ),
    );
  }
}
