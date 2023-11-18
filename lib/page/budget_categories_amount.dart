import 'package:flutter/material.dart';

import '../di.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/crud_handler.dart';
import '../model/item_action.dart';
import '../util/datetime.dart';
import '../widget/budget_category_amount_list.dart';
import 'budget_category_amount.dart';

class BudgetCategoriesAmountPage extends StatefulWidget {
  const BudgetCategoriesAmountPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoriesAmountPageState();
  }
}

class _BudgetCategoriesAmountPageState
    extends State<BudgetCategoriesAmountPage> {
  late CrudHandler<BudgetCategoryAmount> crudHandler;
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
    return BudgetCategoryAmountList(
      crudHandler: crudHandler,
      fromDate: fromDate,
      toDate: toDate,
      onFromDateChange: (value) {
        setState(() {
          fromDate = value;
          crudHandler.reload();
        });
      },
      onToDateChange: (value) {
        setState(() {
          toDate = value;
          crudHandler.reload();
        });
      },
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
            builder: (BuildContext context) => BudgetCategoryAmountPage(
              value: item,
              fromDate: fromDate,
              toDate: toDate,
            ),
          ));
          break;
        }
      case ItemAction.delete:
        {
          await DI().budgetCategoryService().deleteAmount(
                categoryCode: item.category.code,
                fromDate: fromDate,
                toDate: toDate,
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
          builder: (BuildContext context) => BudgetCategoryAmountPage(
            fromDate: fromDate,
            toDate: toDate,
          ),
        ));
        crudHandler.reload();
      },
      tooltip: L10n.of(context).addAction,
      child: const Icon(Icons.add),
    );
  }
}
