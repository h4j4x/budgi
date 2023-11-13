import 'package:budgi/model/budget_category.dart';
import 'package:budgi/widget/common/max_width.dart';
import 'package:budgi/widget/common/responsive.dart';
import 'package:flutter/material.dart';

import '../di.dart';
import '../model/crud_handler.dart';
import '../model/item_action.dart';
import 'common/date_input.dart';

class BudgetCategoryList extends StatefulWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final Function(DateTime) onFromDateChange;
  final Function(DateTime) onToDateChange;

  final CrudHandler<BudgetCategoryAmount> crudHandler;

  const BudgetCategoryList({
    super.key,
    required this.crudHandler,
    required this.fromDate,
    required this.toDate,
    required this.onFromDateChange,
    required this.onToDateChange,
  });

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoryListState();
  }
}

class _BudgetCategoryListState extends State<BudgetCategoryList> {
  final list = <BudgetCategoryAmount>[];

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
    final values = await DI().budgetCategoryService().listAmounts(
          fromDate: widget.fromDate,
          toDate: widget.toDate,
        );
    list.clear();
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
    return ResponsiveWidget(
      mobile: mobile(),
      desktop: mobile(),
    );
  }

  Widget mobile() {
    return Column(
      children: [
        toolBar(),
        ListView.separated(
          shrinkWrap: true,
          itemBuilder: (_, index) {
            return listItem(list[index]);
          },
          separatorBuilder: (_, __) {
            return const Divider();
          },
          itemCount: list.length,
        ),
      ],
    );
  }

  Widget toolBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          MaxWidthWidget(
            maxWidth: 200,
            child: DateInputWidget(
              label: 'FROM DATE', // TODO
              value: widget.fromDate,
              onChange: widget.onFromDateChange,
            ),
          ),
        ],
      ),
    );
  }

  Widget listItem(BudgetCategoryAmount item) {
    return ListTile(
      title: Text(item.budgetCategory.name),
      subtitle: Text('\$${item.amount.toStringAsFixed(2)}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          widget.crudHandler.onItemAction(context, item, ItemAction.delete);
        },
      ),
      onTap: () {
        widget.crudHandler.onItemAction(context, item, ItemAction.select);
      },
    );
  }
}
