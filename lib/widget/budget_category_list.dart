import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/crud_handler.dart';
import '../model/item_action.dart';
import 'common/sliver_center.dart';

class BudgetCategoryList extends StatefulWidget {
  final CrudHandler<BudgetCategory> crudHandler;

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
  final list = <BudgetCategory>[];

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
    final values = await DI().budgetCategoryService().listCategories();
    list.clear();
    list.addAll(values);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SliverCenter(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return body();
  }

  Widget body() {
    if (list.isEmpty) {
      return SliverCenter(
        child: Text(L10n.of(context).nothingHere),
      );
    }
    return SliverList.separated(
      itemBuilder: (_, index) {
        return listItem(list[index]);
      },
      separatorBuilder: (_, __) {
        return const Divider();
      },
      itemCount: list.length,
    );
  }

  Widget listItem(BudgetCategory item) {
    return ListTile(
      title: Text(item.name),
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
