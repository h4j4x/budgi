import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/crud_handler.dart';
import '../model/item_action.dart';
import '../model/period.dart';
import '../util/datetime.dart';

class BudgetCategoryAmountList extends StatefulWidget {
  final Period period;

  final CrudHandler<BudgetCategoryAmount> crudHandler;

  const BudgetCategoryAmountList({
    super.key,
    required this.crudHandler,
    required this.period,
  });

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoryAmountListState();
  }
}

class _BudgetCategoryAmountListState extends State<BudgetCategoryAmountList> {
  final periodController = TextEditingController();
  final list = <BudgetCategoryAmount>[];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      periodController.text = formatDateTimePeriod(
        context,
        period: widget.period,
      );
    });
    widget.crudHandler.reload = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadList();
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
          period: widget.period,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: TextField(
              controller: periodController,
              readOnly: true,
              enabled: false,
            ),
          ),
          IconButton(
            onPressed: loadList,
            icon: AppIcon.reload,
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
        icon: AppIcon.delete,
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
