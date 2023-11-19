import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../page/budget_categories.dart';
import '../page/budget_categories_amount.dart';
import '../page/budget_category.dart';
import '../page/budget_category_amount.dart';
import '../page/home.dart';
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
      return L10n.of(context).budgetsCategoriesAmounts;
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
          child: _AppScaffold(
            path: state.fullPath ?? '',
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

class _AppScaffold extends StatelessWidget {
  final String path;
  final Widget child;
  final routes = _routes.where((route) {
    return route.menuText != null;
  }).toList();

  _AppScaffold({
    required this.child,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title(context)),
      body: SafeArea(child: child),
      drawer: Drawer(
        child: ListView.separated(
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final route = routes[index];
            final selected = route.path == path;
            return ListTile(
              title: Text(route.menuText!(context)),
              leading: route.icon,
              selected: selected,
              onTap: !selected
                  ? () {
                      GoRouter.of(context).go(route.path);
                      Navigator.pop(context);
                    }
                  : null,
            );
          },
          separatorBuilder: (_, __) {
            return const Divider();
          },
        ),
      ),
    );
  }

  Widget? title(BuildContext context) {
    final currentRouteIndex = routes.indexWhere((route) {
      return route.path == path && route.menuText != null;
    });
    if (currentRouteIndex >= 0) {
      final route = routes[currentRouteIndex];
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (route.icon != null) route.icon!,
          if (route.icon != null) const SizedBox(width: 8),
          Text(route.menuText!(context)),
        ],
      );
    }
    return null;
  }
}

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

  void pop<T extends Object?>([T? result]) {
    return GoRouter.of(this).pop(result);
  }
}
