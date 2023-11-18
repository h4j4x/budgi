import 'package:flutter/material.dart';

import '../di.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/crud_handler.dart';
import '../model/item_action.dart';
import '../util/datetime.dart';
import '../widget/budget_category_list.dart';
import 'budget_category.dart';

class BudgetCategoriesPage extends StatefulWidget {
  const BudgetCategoriesPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoriesPageState();
  }
}

class _BudgetCategoriesPageState extends State<BudgetCategoriesPage> {
  late CrudHandler<BudgetCategory> crudHandler;
  late DateTime fromDate;
  late DateTime toDate;

  @override
  void initState() {
    super.initState();
    crudHandler = CrudHandler(onItemAction: onItemAction);
    fromDate = DateTime.now().atStartOfDay(); // TODO
    toDate = fromDate.add(const Duration(days: 1)); // TODO
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: body(),
      floatingActionButton: addButton(),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      title: Text(L10n.of(context).budgets),
      actions: [
        IconButton(
          onPressed: crudHandler.reload,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget body() {
    return BudgetCategoryList(
      crudHandler: crudHandler,
    );
  }

  void onItemAction(
    BuildContext context,
    BudgetCategory item,
    ItemAction action,
  ) async {
    switch (action) {
      case ItemAction.select:
        {
          await Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => BudgetCategoryPage(
              value: item,
            ),
          ));
          break;
        }
      case ItemAction.delete:
        {
          await DI().budgetCategoryService().deleteCategory(
                code: item.code,
              );
          break;
        }
    }
    crudHandler.reload();
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (BuildContext context) => const BudgetCategoryPage(),
        ));
        crudHandler.reload();
      },
      tooltip: L10n.of(context).addAction,
      child: const Icon(Icons.add),
    );
  }
}
