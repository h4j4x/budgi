import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../model/category.dart';
import '../../model/crud_handler.dart';
import '../../model/item_action.dart';
import '../../model/period.dart';
import '../../service/category.dart';
import '../../util/ui.dart';
import '../common/sliver_center.dart';

class CategoryAmountList extends StatefulWidget {
  final Period period;

  final CrudHandler<CategoryAmount> crudHandler;

  const CategoryAmountList({
    super.key,
    required this.crudHandler,
    required this.period,
  });

  @override
  State<StatefulWidget> createState() {
    return _CategoryAmountListState();
  }
}

class _CategoryAmountListState extends State<CategoryAmountList> {
  final list = <CategoryAmount>[];

  bool loading = false;

  @override
  void initState() {
    super.initState();
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
    final values = await DI().get<CategoryService>().listAmounts(
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

  Widget listItem(CategoryAmount item) {
    return ListTile(
      title: Text(item.category.name),
      subtitle: Text('\$${item.amount.toStringAsFixed(2)}'),
      trailing: IconButton(
        icon: AppIcon.delete(context),
        onPressed: () async {
          final l10n = L10n.of(context);
          final confirm = await context.confirm(
            title: l10n.budgetAmountDelete,
            description: l10n.budgetAmountDeleteConfirm(item.category.name),
          );
          if (confirm && mounted) {
            widget.crudHandler.onItemAction(context, item, ItemAction.delete);
          }
        },
      ),
      onTap: () {
        widget.crudHandler.onItemAction(context, item, ItemAction.select);
      },
    );
  }
}
