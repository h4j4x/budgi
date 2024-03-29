import 'dart:async';

import 'package:flutter/material.dart';

import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../service/auth.dart';
import 'home.dart';
import 'sign_in.dart';

class SplashPage extends StatefulWidget {
  static const route = '/splash';

  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, fetchAuth);
  }

  void fetchAuth() async {
    if (DI().has<AuthService>()) {
      final user = DI().get<AuthService>().user();
      redirect(user != null);
    } else {
      redirect(true);
    }
  }

  void redirect(bool isAuthenticated) {
    final route = isAuthenticated ? HomePage.route : SignInPage.route;
    debugPrint('Splash redirecting to $route');
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).appTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: body(),
    );
  }

  Widget body() {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}
