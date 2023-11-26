import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../app/info.dart';
import '../../app/router.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../service/auth.dart';

class AppScaffold extends StatefulWidget {
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
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  String version = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      version = await DI().get<AppInfo>().version();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = DI().get<AuthService>().user();
    return Scaffold(
      appBar: AppBar(
        title: title(context),
        actions: [
          if (user != null)
            TextButton.icon(
              onPressed: () {},
              icon: user.icon,
              label: Text(user.name),
            ),
        ],
      ),
      body: SafeArea(child: widget.child),
      drawer: Drawer(
        child: ListView.separated(
          itemCount: widget.routes.length + 1,
          itemBuilder: (context, index) {
            if (index < widget.routes.length) {
              return routeWidget(context, widget.routes[index]);
            }
            return aboutWidget(context);
          },
          separatorBuilder: (_, __) {
            return const Divider();
          },
        ),
      ),
    );
  }

  Widget? title(BuildContext context) {
    final currentRouteIndex = widget.routes.indexWhere((route) {
      return route.path == widget.path && route.menuText != null;
    });
    if (currentRouteIndex >= 0) {
      final route = widget.routes[currentRouteIndex];
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

  Widget routeWidget(BuildContext context, AppRoute route) {
    final selected = route.path == widget.path;
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
  }

  Widget aboutWidget(BuildContext context) {
    return ListTile(
      enabled: false,
      title: Text(L10n.of(context).appAbout(version, DateTime.now().year)),
      leading: AppIcon.about,
    );
  }
}
