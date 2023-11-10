import 'package:budgi/model/budget_category.dart';
import 'package:budgi/widget/common/responsive.dart';
import 'package:flutter/material.dart';

import '../di.dart';
import '../model/crud_handler.dart';

class BudgetCategoryList extends StatefulWidget {
  final CrudHandler crudHandler;

  const BudgetCategoryList({
    super.key,
    required this.crudHandler,
  });

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoryListState();
  }
}

class _BudgetCategoryListState extends State<BudgetCategoryList> {
  final list = <BudgetCategoryAmount>{};

  bool loading = false;

  @override
  void initState() {
    super.initState();
    widget.crudHandler.reload = loadList;
    Future.delayed(Duration.zero, loadList);
  }

  void loadList() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    final fromDate = DateTime.now(); // TODO
    final toDate = fromDate.add(const Duration(days: 1)); // TODO
    final values = await DI().getBudgetCategoryService().listAmounts(
          fromDate: fromDate,
          toDate: toDate,
        );
    list.addAll(values);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
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
