import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/category.dart';
import '../model/item_action.dart';
import '../model/state/crud.dart';
import '../service/category.dart';
import '../widget/domain/category_list.dart';
import 'category.dart';

class CategoriesPage extends StatelessWidget {
  static const route = '/categories';

  const CategoriesPage({super.key});

  void loadList(BuildContext context) {
    context.read<CrudState<Category>>().load();
  }

  Future<List<Category>> load() async {
    return DI().get<CategoryService>().listCategories();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CrudState<Category>>(
      create: (_) {
        return CrudState<Category>(loader: load);
      },
      builder: (context, child) {
        return Scaffold(
          body: body(context),
          floatingActionButton: addButton(context),
        );
      },
    );
  }

  Widget body(BuildContext context) {
    return CustomScrollView(
      slivers: [
        toolbar(context),
        CategoryList(onItemAction: onItemAction),
      ],
    );
  }

  Widget toolbar(BuildContext context) {
    return SliverAppBar(
      actions: [
        IconButton(
          onPressed: () {
            loadList(context);
          },
          icon: AppIcon.reload,
        ),
      ],
    );
  }

  void onItemAction(
    BuildContext context,
    Category item,
    ItemAction action,
  ) async {
    switch (action) {
      case ItemAction.select:
        {
          await context.push(CategoryPage.route, extra: item);
          break;
        }
      case ItemAction.delete:
        {
          await DI().get<CategoryService>().deleteCategory(
                code: item.code,
              );
          break;
        }
    }
    if (context.mounted) {
      loadList(context);
    }
  }

  Widget addButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(CategoryPage.route);
        if (context.mounted) {
          loadList(context);
        }
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
