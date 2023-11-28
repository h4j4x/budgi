import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../app/config.dart';
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFocus = FocusNode();

  StreamSubscription<bool>? authSubscription;

  bool processing = false;

  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      authSubscription = DI().get<AuthService>().authenticatedStream().listen((isAuthenticated) {
        if (isAuthenticated) {
          context.go(HomePage.route);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      emailField(),
      passwordField(),
      Center(child: signInButton()),
      const Divider(),
      Center(child: githubButton()),
    ];
    if (processing) {
      items.insert(
        0,
        const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.separated(
          itemBuilder: (_, index) {
            return items[index];
          },
          separatorBuilder: (_, __) {
            return const Divider(color: Colors.transparent);
          },
          itemCount: items.length,
        ),
      ),
    );
  }

  Widget emailField() {
    final l10n = L10n.of(context);
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofocus: true,
      enabled: !processing,
      decoration: InputDecoration(
        labelText: l10n.userEmail,
        hintText: l10n.userEmailHint,
        errorText: emailError,
      ),
      onChanged: (_) {
        setState(() {
          emailError = null;
        });
      },
      onSubmitted: (_) {
        passwordFocus.requestFocus();
      },
    );
  }

  Widget passwordField() {
    final l10n = L10n.of(context);
    return TextField(
      controller: passwordController,
      obscureText: true,
      textInputAction: TextInputAction.go,
      enabled: !processing,
      decoration: InputDecoration(
        labelText: l10n.userPassword,
        hintText: l10n.userPasswordHint,
        errorText: passwordError,
      ),
      onChanged: (_) {
        setState(() {
          passwordError = null;
        });
      },
      onSubmitted: (_) {
        onSignIn();
      },
    );
  }

  Widget signInButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220, minWidth: 100),
      child: TextButton.icon(
        icon: AppIcon.signIn,
        label: Text(L10n.of(context).signIn),
        style: ElevatedButtonTheme.of(context).style,
        onPressed: !processing ? onSignIn : null,
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

  void onSignIn() async {
    final email = emailController.text;
    if (email.isEmpty && email.indexOf('@') != 1) {
      setState(() {
        emailError = L10n.of(context).invalidUserEmail;
      });
      return;
    }
    final password = passwordController.text;
    if (password.length < AppConfig.passwordMinLength) {
      setState(() {
        emailError = L10n.of(context).invalidUserPassword(AppConfig.passwordMinLength);
      });
      return;
    }

    setState(() {
      processing = true;
    });
    final success = await DI().get<AuthService>().signIn(context, email: email, password: password);
    if (success && mounted) {
      context.go(HomePage.route);
    } else {
      // TODO: show error message
      setState(() {
        processing = false;
      });
    }
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
    emailController.dispose();
    passwordController.dispose();
    authSubscription?.cancel();
    super.dispose();
  }
}
