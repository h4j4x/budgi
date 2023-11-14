import 'package:flutter/material.dart';

import 'di.dart';
import 'l10n/l10n.dart';
import 'page/budget_categories.dart';

void main() {
  DI().setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => L10n.of(context).appTitle,
      theme: ThemeData(
        // TODO
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: const BudgetCategoriesPage(), // TODO
    );
  }
}
