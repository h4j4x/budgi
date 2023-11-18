import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'model/budget_category.dart';
import 'page/budget_categories.dart';
import 'page/budget_categories_amount.dart';
import 'page/budget_category.dart';
import 'page/budget_category_amount.dart';
import 'page/home.dart';

extension RouterContext on BuildContext {
  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    return GoRouter.of(this).push<T>(location, extra: extra);
  }

  void pop<T extends Object?>([T? result]) {
    return GoRouter.of(this).pop(result);
  }
}

// https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html
final router = GoRouter(
  routes: [
    GoRoute(
      path: HomePage.route,
      builder: (_, __) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: BudgetCategoriesPage.route,
      builder: (_, __) {
        return const BudgetCategoriesPage();
      },
    ),
    GoRoute(
      path: BudgetCategoryPage.route,
      builder: (_, state) {
        return BudgetCategoryPage(value: state.extra as BudgetCategory?);
      },
    ),
    GoRoute(
      path: BudgetCategoriesAmountPage.route,
      builder: (_, __) {
        return const BudgetCategoriesAmountPage();
      },
    ),
    GoRoute(
      path: BudgetCategoryAmountPage.route,
      builder: (_, state) {
        if (state.extra is BudgetCategoryAmountData) {
          return BudgetCategoryAmountPage.data(
            state.extra as BudgetCategoryAmountData,
          );
        }
        return const HomePage();
      },
    ),
  ],
);
