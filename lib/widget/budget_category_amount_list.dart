import 'package:flutter/material.dart';

import '../di.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/crud_handler.dart';
import '../model/item_action.dart';
import 'common/date_input.dart';

class BudgetCategoryAmountList extends StatefulWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final Function(DateTime) onFromDateChange;
  final Function(DateTime) onToDateChange;

  final CrudHandler<BudgetCategoryAmount> crudHandler;

  const BudgetCategoryAmountList({
    super.key,
    required this.crudHandler,
    required this.fromDate,
    required this.toDate,
    required this.onFromDateChange,
    required this.onToDateChange,
  });

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoryAmountListState();
  }
}

class _BudgetCategoryAmountListState extends State<BudgetCategoryAmountList> {
  final list = <BudgetCategoryAmount>[];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    widget.crudHandler.reload = () {
      Future.delayed(Duration.zero, () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loadList();
        });
      });
    };
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
    return body();
  }

  Widget body() {
    return Column(
      children: [
        toolBar(),
        const Divider(),
        if (list.isEmpty) const Spacer(),
        if (list.isEmpty) Text(L10n.of(context).nothingHere),
        if (list.isEmpty) const Spacer(),
        if (list.isNotEmpty)
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
    final l10n = L10n.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Wrap(
        runSpacing: 8,
        spacing: 8,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: DateInputWidget(
              label: l10n.fromDate,
              value: widget.fromDate,
              maxValue: widget.toDate.add(const Duration(days: -1)),
              onChange: widget.onFromDateChange,
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: DateInputWidget(
              label: l10n.toDate,
              minValue: widget.fromDate.add(const Duration(days: 1)),
              value: widget.toDate,
              onChange: widget.onToDateChange,
            ),
          ),
        ],
      ),
    );
  }

  Widget listItem(BudgetCategoryAmount item) {
    return ListTile(
      title: Text(item.category.name),
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
