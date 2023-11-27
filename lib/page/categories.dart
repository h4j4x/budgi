import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/category.dart';
import '../util/function.dart';
import '../model/item_action.dart';
import '../service/category.dart';
import '../widget/entity/category_list.dart';
import 'category.dart';

class CategoriesPage extends StatefulWidget {
  static const route = '/categories';

  const CategoriesPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CategoriesPageState();
  }
}

class _CategoriesPageState extends State<CategoriesPage> {
  late CrudHandler<Category> crudHandler;

  @override
  void initState() {
    super.initState();
    crudHandler = CrudHandler(onItemAction: onItemAction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        toolbar(),
        CategoryList(
          crudHandler: crudHandler,
        ),
      ],
    );
  }

  Widget toolbar() {
    return SliverAppBar(
      actions: [
        IconButton(
          onPressed: crudHandler.reload,
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
    crudHandler.reload();
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(CategoryPage.route);
        crudHandler.reload();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
