import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../widget/sign_in.dart';

class SignInPage extends StatelessWidget {
  static const route = '/sign-in';

  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).appTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: const SignIn(),
    );
  }
}
