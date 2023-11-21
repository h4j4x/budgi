import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/crud_handler.dart';
import '../model/item_action.dart';
import '../util/datetime.dart';
import '../widget/budget_category_list.dart';
import 'budget_category.dart';

class BudgetCategoriesPage extends StatefulWidget {
  static const route = '/categories';

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
      // appBar: appBar(),
      body: body(),
      floatingActionButton: addButton(),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      actions: [
        IconButton(
          onPressed: crudHandler.reload,
          icon: AppIcon.reload,
        ),
      ],
    );
  }

  Widget body() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          actions: [
            IconButton(
              onPressed: crudHandler.reload,
              icon: AppIcon.reload,
            ),
          ],
        ),
        BudgetCategoryList(
          crudHandler: crudHandler,
        ),
      ],
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
          await context.push(BudgetCategoryPage.route, extra: item);
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
        await context.push(BudgetCategoryPage.route);
        crudHandler.reload();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
