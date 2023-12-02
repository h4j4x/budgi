import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/category.dart';
import '../model/item_action.dart';
import '../service/category.dart';
import '../widget/domain/category_list.dart';
import 'category.dart';

class CategoriesPage extends StatefulWidget {
  static const route = '/categories';

  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final list = <Category>[];

  bool loading = false;

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, loadList);
  }

  void loadList() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    final newList = await DI().get<CategoryService>().listCategories();
    list.clear();
    list.addAll(newList);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      floatingActionButton: addButton(),
    );
  }

  Widget body() {
    return CustomScrollView(
      slivers: [
        toolbar(),
        CategoryList(
          list: list,
          enabled: !loading,
          onItemAction: onItemAction,
        ),
      ],
    );
  }

  Widget toolbar() {
    return SliverAppBar(
      actions: [
        IconButton(
          onPressed: loadList,
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
    if (mounted) {
      loadList();
    }
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(CategoryPage.route);
        if (mounted) {
          loadList();
        }
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
