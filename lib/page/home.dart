import 'package:flutter/material.dart';

import '../app/router.dart';
import 'budget_categories.dart';
import 'budget_categories_amount.dart';

class HomePage extends StatelessWidget {
  static const route = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                context.push(BudgetCategoriesPage.route);
              },
              child: const Text('CATEGORIES TODO'),
            ),
            ElevatedButton(
              onPressed: () {
                context.push(BudgetCategoriesAmountPage.route);
              },
              child: const Text('CATEGORIES AMOUNTS TODO'),
            ),
          ],
        ),
      ),
    );
  }
}
