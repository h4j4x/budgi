import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../page/home.dart';
import '../service/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignIn> {
  StreamSubscription<bool>? authSubscription;

  bool processing = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      authSubscription = DI()
          .get<AuthService>()
          .authenticatedStream()
          .listen((isAuthenticated) {
        if (isAuthenticated) {
          context.go(HomePage.route);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      githubButton(),
    ];
    if (processing) {
      items.insert(
        0,
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items,
        ),
      ),
    );
  }

  Widget githubButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220, minWidth: 100),
      child: TextButton.icon(
        icon: AppIcon.github,
        label: Text(L10n.of(context).signInGithub),
        style: ElevatedButtonTheme.of(context).style,
        onPressed: !processing ? onGithub : null,
      ),
    );
  }

  void onGithub() async {
    setState(() {
      processing = true;
    });
    final success = await DI().get<AuthService>().signInWithGithub(context);
    if (success && mounted) {
      context.go(HomePage.route);
    } else {
      // TODO: show error message
      setState(() {
        processing = false;
      });
    }
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    super.dispose();
  }
}
