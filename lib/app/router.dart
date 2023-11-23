import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';
import '../model/category.dart';
import '../model/transaction.dart';
import '../model/wallet.dart';
import '../page/categories.dart';
import '../page/categories_amounts.dart';
import '../page/category.dart';
import '../page/category_amount.dart';
import '../page/home.dart';
import '../page/transaction.dart';
import '../page/transactions.dart';
import '../page/wallet.dart';
import '../page/wallets.dart';
import '../widget/app/layout.dart';
import 'icon.dart';

final _routes = <AppRoute>[
  // home
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
  // budget categories
  AppRoute(
    path: CategoriesPage.route,
    icon: AppIcon.category,
    menuText: (context) {
      return L10n.of(context).budgetsCategories;
    },
    pageBuilder: (_, __) {
      return const CategoriesPage();
    },
  ),
  // budget category
  AppRoute(
    path: CategoryPage.route,
    pageBuilder: (_, state) {
      return CategoryPage(value: state.extra as Category?);
    },
  ),
  // budget categories amounts
  AppRoute(
    path: CategoriesAmountsPage.route,
    icon: AppIcon.categoryAmount,
    menuText: (context) {
      return L10n.of(context).budgetsAmounts;
    },
    pageBuilder: (_, __) {
      return const CategoriesAmountsPage();
    },
  ),
  // budget category amount
  AppRoute(
    path: CategoryAmountPage.route,
    pageBuilder: (_, state) {
      if (state.extra is CategoryAmountData) {
        return CategoryAmountPage.data(
          state.extra as CategoryAmountData,
        );
      }
      return const HomePage();
    },
  ),
  // wallets
  AppRoute(
    path: WalletsPage.route,
    icon: AppIcon.wallet,
    menuText: (context) {
      return L10n.of(context).wallets;
    },
    pageBuilder: (_, __) {
      return const WalletsPage();
    },
  ),
  // wallet
  AppRoute(
    path: WalletPage.route,
    pageBuilder: (_, state) {
      return WalletPage(value: state.extra as Wallet?);
    },
  ),
  // transactions
  AppRoute(
    path: TransactionsPage.route,
    icon: AppIcon.transaction,
    menuText: (context) {
      return L10n.of(context).transactions;
    },
    pageBuilder: (_, __) {
      return const TransactionsPage();
    },
  ),
  // wallet
  AppRoute(
    path: TransactionPage.route,
    pageBuilder: (_, state) {
      return TransactionPage(value: state.extra as Transaction?);
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
  final Widget? icon;
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
