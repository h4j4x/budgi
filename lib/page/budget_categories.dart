import 'package:budgi/model/budget_category.dart';
import 'package:budgi/model/crud_handler.dart';
import 'package:budgi/page/budget_category.dart';
import 'package:flutter/material.dart';

import '../widget/budget_category_list.dart';

class BudgetCategoriesPage extends StatefulWidget {
  const BudgetCategoriesPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoriesPageState();
  }
}

class _BudgetCategoriesPageState extends State<BudgetCategoriesPage> {
  late CrudHandler<BudgetCategoryAmount> crudHandler;

  @override
  void initState() {
    super.initState();
    crudHandler = CrudHandler(onItemAction: onItemAction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('BudgetCategories'), // TODO
        actions: [
          IconButton(
            onPressed: crudHandler.reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BudgetCategoryList(crudHandler: crudHandler),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => const BudgetCategoryPage(),
          ));
          crudHandler.reload();
        },
        tooltip: 'Add', // TODO
        child: const Icon(Icons.add),
      ),
    );
  }

  void onItemAction(BuildContext context, BudgetCategoryAmount item) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => BudgetCategoryPage(value: item),
    ));
    crudHandler.reload();
  }
}
