import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../app/info.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/user.dart';
import '../../page/sign_in.dart';
import '../../service/auth.dart';
import '../common/responsive.dart';
import '../common/side_collapsible.dart';

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
  StreamSubscription<bool>? authSubscription;

  String version = '';
  bool menuCollapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      version = await DI().get<AppInfo>().version();
      setState(() {});
      checkUser();
    });
  }

  AppUser? get appUser {
    if (DI().has<AuthService>()) {
      return DI().get<AuthService>().user();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = appUser;
    return ResponsiveWidget(
      mobile: Scaffold(
        appBar: appBar(user, true),
        body: SafeArea(child: widget.child),
        drawer: Drawer(
          child: menu(user, true),
        ),
      ),
      desktop: Scaffold(
        appBar: appBar(user, false),
        body: SafeArea(
          child: SideCollapsibleWidget(
            sideCollapsed: menuCollapsed,
            side: menu(user, false),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget appBar(AppUser? user, bool isMobile) {
    return AppBar(
      leading: !isMobile
          ? IconButton(
              icon: AppIcon.menu,
              onPressed: () {
                setState(() {
                  menuCollapsed = !menuCollapsed;
                });
              },
            )
          : null,
      title: title(),
      actions: [
        if (user != null && isMobile)
          IconButton(
            onPressed: () {},
            icon: user.icon(),
            tooltip: user.name,
          ),
        if (user != null && !isMobile)
          TextButton.icon(
            onPressed: () {},
            icon: user.icon(),
            label: Text(user.name),
          ),
      ],
    );
  }

  Widget? title() {
    final currentRouteIndex = widget.routes.indexWhere((route) {
      return route.path == widget.path;
    });
    if (currentRouteIndex >= 0) {
      final route = widget.routes[currentRouteIndex];
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (route.icon != null) route.icon!,
          if (route.icon != null) const SizedBox(width: 4),
          Expanded(child: route.menuBuilder(context)),
        ],
      );
    }
    return null;
  }

  Widget menu(AppUser? user, bool isMobile) {
    final items = <Widget>[
      ...widget.routes.map(routeWidget),
      aboutWidget(),
    ];
    if (user != null) {
      if (isMobile) {
        items.insert(0, headerWidget(user));
      }
      items.add(signOutWidget());
    }
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return items[index];
      },
      separatorBuilder: (_, index) {
        if (isMobile && index == 0) {
          return Container();
        }
        return const Divider();
      },
    );
  }

  Widget headerWidget(AppUser user) {
    final theme = Theme.of(context);
    final foregroundColor = theme.colorScheme.onPrimaryContainer;
    final backgroundColor = theme.colorScheme.primaryContainer;
    return DrawerHeader(
      decoration: BoxDecoration(
        color: backgroundColor,
      ), //BoxDecoration
      child: UserAccountsDrawerHeader(
        decoration: BoxDecoration(color: backgroundColor),
        accountName: Text(
          user.name,
          textScaler: const TextScaler.linear(1.2),
          style: TextStyle(color: foregroundColor),
        ),
        accountEmail: Text(
          user.email ?? user.username,
          style: TextStyle(color: foregroundColor),
        ),
        currentAccountPictureSize: const Size.square(40),
        currentAccountPicture: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: user.icon(size: 20, color: theme.colorScheme.onPrimary), //Text
        ), //circleAvatar
      ), //UserAccountDrawerHeader
    );
  }

  Widget routeWidget(AppRoute route) {
    final selected = route.path == widget.path;
    final onTap = !selected
        ? () {
            context.go(route.path);
            context.pop();
          }
        : null;
    if (menuCollapsed) {
      return IconButton(
        onPressed: onTap,
        icon: route.icon ?? Container(),
        tooltip: route.menuTextBuilder != null
            ? route.menuTextBuilder!(context)
            : null,
      );
    }
    return ListTile(
      title: route.menuBuilder(context),
      leading: route.icon,
      selected: selected,
      onTap: onTap,
    );
  }

  Widget aboutWidget() {
    final aboutText = L10n.of(context).appAbout(version, DateTime.now().year);
    if (menuCollapsed) {
      return IconButton(
        onPressed: null,
        icon: AppIcon.about,
        tooltip: aboutText,
      );
    }
    return ListTile(
      enabled: false,
      title: !menuCollapsed
          ? Text(
              aboutText,
              textScaler: const TextScaler.linear(0.8),
            )
          : null,
      leading: AppIcon.about,
    );
  }

  Widget signOutWidget() {
    if (menuCollapsed) {
      return IconButton(
        onPressed: onSignOut,
        icon: AppIcon.signOut(context),
        tooltip: L10n.of(context).signOut,
      );
    }
    return ListTile(
      title: Text(
        L10n.of(context).signOut,
        style: TextStyle(
          color: Theme.of(context).colorScheme.warning,
        ),
      ),
      leading: AppIcon.signOut(context),
      onTap: onSignOut,
    );
  }

  void onSignOut() async {
    await DI().get<AuthService>().signOut();
  }

  void checkUser() {
    if (DI().has<AuthService>()) {
      authSubscription =
          DI().get<AuthService>().authenticatedStream().listen(redirect);
      try {
        DI().get<AuthService>().fetchUser(errorIfMissing: '');
      } catch (_) {}
    }
  }

  void redirect(bool isAuthenticated) {
    if (!isAuthenticated && mounted) {
      authSubscription?.cancel();
      debugPrint('Home redirecting to SignIn');
      context.go(SignInPage.route);
    }
  }
}
