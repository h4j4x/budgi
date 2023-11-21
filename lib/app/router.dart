import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../page/budget_categories.dart';
import '../page/budget_categories_amount.dart';
import '../page/budget_category.dart';
import '../page/budget_category_amount.dart';
import '../page/home.dart';
import '../widget/app/layout.dart';
import 'icon.dart';

final _routes = <AppRoute>[
  AppRoute(
    path: HomePage.route,
    icon: AppIcon.home,
    menuText: (context) {
      return L10n.of(context).home;
    },
    pageBuilder: (_, __) {
      return const HomePage();
    },
  ),
  AppRoute(
    path: BudgetCategoriesPage.route,
    icon: AppIcon.budgetCategory,
    menuText: (context) {
      return L10n.of(context).budgetsCategories;
    },
    pageBuilder: (_, __) {
      return const BudgetCategoriesPage();
    },
  ),
  AppRoute(
    path: BudgetCategoryPage.route,
    pageBuilder: (_, state) {
      return BudgetCategoryPage(value: state.extra as BudgetCategory?);
    },
  ),
  AppRoute(
    path: BudgetCategoriesAmountPage.route,
    icon: AppIcon.budgetCategoryAmount,
    menuText: (context) {
      return L10n.of(context).budgetsAmounts;
    },
    pageBuilder: (_, __) {
      return const BudgetCategoriesAmountPage();
    },
  ),
  AppRoute(
    path: BudgetCategoryAmountPage.route,
    pageBuilder: (_, state) {
      if (state.extra is BudgetCategoryAmountData) {
        return BudgetCategoryAmountPage.data(
          state.extra as BudgetCategoryAmountData,
        );
      }
      return const HomePage();
    },
  ),
];

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _menuRoutes = _routes.where((route) {
  return route.menuText != null;
}).toList();

// https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html
final router = GoRouter(
  initialLocation: HomePage.route,
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      parentNavigatorKey: _rootNavigatorKey,
      navigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state, child) {
        return NoTransitionPage(
          child: AppScaffold(
            path: state.fullPath ?? '',
            routes: _menuRoutes,
            child: child,
          ),
        );
      },
      routes: _routes.map((route) {
        return GoRoute(
          path: route.path,
          parentNavigatorKey: _shellNavigatorKey,
          pageBuilder: (context, state) {
            final child = route.pageBuilder(context, state);
            return NoTransitionPage(child: child);
          },
        );
      }).toList(),
    ),
  ],
);

typedef TextBuilder = String Function(BuildContext);

typedef PageWidgetBuilder = Widget Function(BuildContext, GoRouterState state);

class AppRoute {
  final String path;
  final TextBuilder? menuText;
  final Icon? icon;
  final PageWidgetBuilder pageBuilder;

  AppRoute({
    required this.path,
    required this.pageBuilder,
    this.menuText,
    this.icon,
  });
}

extension RouterContext on BuildContext {
  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    return GoRouter.of(this).push<T>(location, extra: extra);
  }

  void go(String location, {Object? extra}) {
    GoRouter.of(this).go(location, extra: extra);
  }

  void pop<T extends Object?>([T? result]) {
    return GoRouter.of(this).pop(result);
  }
}
