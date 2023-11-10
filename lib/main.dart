import 'package:budgi/di.dart';
import 'package:budgi/page/budget_categories.dart';
import 'package:flutter/material.dart';

void main() {
  DI().setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', // TODO
      theme: ThemeData(
        // TODO
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BudgetCategoriesPage(), // TODO
    );
  }
}
