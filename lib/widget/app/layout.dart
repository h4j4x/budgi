import 'package:flutter/material.dart';

import '../../app/router.dart';

class AppScaffold extends StatelessWidget {
  final String path;
  final List<AppRoute> routes;
  final Widget child;

  const AppScaffold({
    super.key,
    required this.path,
    required this.routes,
    required this.child,
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
                      context.go(route.path);
                      context.pop();
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
          if (route.icon != null) const SizedBox(width: 4),
          Expanded(child: Text(route.menuText!(context))),
        ],
      );
    }
    return null;
  }
}
