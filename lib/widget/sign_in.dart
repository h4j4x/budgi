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
  bool processing = false;

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
      child: ElevatedButton(
        onPressed: !processing ? onGithub : null,
        child: Row(
          children: [
            AppIcon.github,
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(L10n.of(context).signInGithub),
            )),
          ],
        ),
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
}
