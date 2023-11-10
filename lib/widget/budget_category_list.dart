import 'package:budgi/widget/common/responsive.dart';
import 'package:flutter/material.dart';

class BudgetCategoryList extends StatefulWidget {
  const BudgetCategoryList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoryListState();
  }
}

class _BudgetCategoryListState extends State<BudgetCategoryList> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(mobile: mobile(), desktop: desktop());
  }

  Widget mobile() {
    return const Center(
      child: Text('MOBILE'), // TODO
    );
  }

  Widget desktop() {
    return const Center(
      child: Text('DESKTOP'), // TODO
    );
  }
}
