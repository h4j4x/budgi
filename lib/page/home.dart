import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static const route = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // todo: period selector (defaults to current) and list with wallets balance (with sort by amount)
    return const Scaffold(
      body: Center(
        child: Text(
          'TODO',
        ),
      ),
    );
  }
}
