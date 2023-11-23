import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../model/category.dart';
import '../../model/crud_handler.dart';
import '../../model/item_action.dart';
import '../../service/category.dart';
import '../../util/ui.dart';
import '../common/sliver_center.dart';

class CategoryList extends StatefulWidget {
  final CrudHandler<Category> crudHandler;

  const CategoryList({
    super.key,
    required this.crudHandler,
  });

  @override
  State<StatefulWidget> createState() {
    return _CategoryListState();
  }
}

class _CategoryListState extends State<CategoryList> {
  final list = <Category>[];

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
    final values = await DI().get<CategoryService>().listCategories();
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

  Widget listItem(Category item) {
    return ListTile(
      title: Text(item.name),
      trailing: IconButton(
        icon: AppIcon.delete(context),
        onPressed: () async {
          final l10n = L10n.of(context);
          final confirm = await context.confirm(
            title: l10n.budgetCategoryDelete,
            description: l10n.budgetCategoryDeleteConfirm(item.name),
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
