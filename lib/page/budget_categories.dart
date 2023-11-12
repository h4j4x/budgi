import 'package:budgi/di.dart';
import 'package:budgi/model/budget_category.dart';
import 'package:budgi/model/crud_handler.dart';
import 'package:budgi/model/item_action.dart';
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
  late DateTime fromDate;
  late DateTime toDate;

  @override
  void initState() {
    super.initState();
    crudHandler = CrudHandler(onItemAction: onItemAction);
    fromDate = DateTime.now(); // TODO
    toDate = fromDate.add(const Duration(days: 1)); // TODO
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
      body: BudgetCategoryList(
        crudHandler: crudHandler,
        fromDate: fromDate,
        toDate: toDate,
      ),
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

  void onItemAction(
    BuildContext context,
    BudgetCategoryAmount item,
    ItemAction action,
  ) async {
    switch (action) {
      case ItemAction.select:
        {
          await Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => BudgetCategoryPage(value: item),
          ));
          break;
        }
      case ItemAction.delete:
        {
          await DI().budgetCategoryService().deleteAmount(
                code: item.budgetCategory.code,
                fromDate: fromDate,
                toDate: toDate,
              );
          break;
        }
    }
    crudHandler.reload();
  }
}
