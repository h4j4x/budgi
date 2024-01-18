import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/data_page.dart';
import '../model/domain/category.dart';
import '../model/error/category.dart';
import '../model/error/validation.dart';
import '../model/fetch_mode.dart';
import '../model/table.dart';
import '../service/category.dart';
import '../util/ui.dart';
import '../widget/common/domain_list.dart';
import 'category.dart';

class CategoriesPage extends StatefulWidget {
  static const route = '/categories';

  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

const _tableCodeCell = 'code';
const _tableNameCell = 'name';

class _CategoriesPageState extends State<CategoriesPage> {
  final dataPage = DataPage.empty<Category>();
  final scrollController = ScrollController();
  final selectedCodes = <String>{};

  bool initialLoading = true;
  bool loading = false;

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      scrollController.addListener(scrollListener);
      loadData(FetchMode.clear);
    });
  }

  void loadData(FetchMode fetchMode, [int? pageNumber]) async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    dataPage.apply(fetchMode, pageNumber);
    final newDataPage = await DI().get<CategoryService>().listCategories(
          page: dataPage.nextPageNumber,
          pageSize: dataPage.pageSize,
        );
    dataPage.add(newDataPage);
    setState(() {
      initialLoading = false;
      loading = false;
    });
  }

  void scrollListener() {
    if (dataPage.hasNextPage &&
        scrollController.offset >=
            scrollController.position.maxScrollExtent - 10 &&
        !scrollController.position.outOfRange) {
      loadData(FetchMode.nextPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      floatingActionButton: addButton(),
    );
  }

  Widget body() {
    final l10n = L10n.of(context);
    return DomainList<Category, String>(
      scrollController: scrollController,
      actions: actions(),
      dataPage: dataPage,
      tableColumns: <TableColumn>[
        TableColumn(key: _tableCodeCell, label: l10n.code, widthPercent: 10),
        TableColumn(key: _tableNameCell, label: l10n.categoryName),
        TableColumn(
            key: 'icons',
            label: '',
            fixedWidth: 100,
            alignment: Alignment.center),
      ],
      initialLoading: initialLoading,
      loadingNextPage: loading,
      itemBuilder: listItem,
      itemCellBuilder: cellItem,
      onPageNavigation: (page) {
        loadData(FetchMode.refreshPage, page);
      },
      selectedKeys: selectedCodes,
      onKeySelect: (code, selected) {
        if (selected) {
          selectedCodes.add(code);
        } else {
          selectedCodes.remove(code);
        }
        setState(() {});
      },
      keyOf: (category) {
        return category.code;
      },
    );
  }

  List<Widget> actions() {
    final actions = <Widget>[
      IconButton(
        onPressed: !loading
            ? () {
                loadData(FetchMode.clear);
              }
            : null,
        icon: AppIcon.reload,
      ),
    ];
    if (selectedCodes.isNotEmpty) {
      actions.addAll(<Widget>[
        const VerticalDivider(),
        IconButton(
          onPressed: !loading
              ? () {
                  setState(() {
                    selectedCodes.clear();
                  });
                }
              : null,
          icon: AppIcon.clear,
        ),
        IconButton(
          onPressed: !loading
              ? () {
                  deleteSelected();
                }
              : null,
          icon: AppIcon.delete(context),
        ),
      ]);
    }
    return actions;
  }

  Widget listItem(BuildContext context, Category category, _, bool selected) {
    return ListTile(
      selected: selected,
      leading: selected ? AppIcon.selected : null,
      title: Text(category.name),
      subtitle: categoryCodeWidget(category),
      trailing: IconButton(
        icon: AppIcon.delete(context),
        onPressed: !loading
            ? () {
                deleteCategory(category);
              }
            : null,
      ),
      onTap: !loading
          ? () {
              editCategory(category);
            }
          : null,
      onLongPress: !loading
          ? () {
              if (selectedCodes.contains(category.code)) {
                selectedCodes.remove(category.code);
              } else {
                selectedCodes.add(category.code);
              }
              setState(() {});
            }
          : null,
    );
  }

  Widget cellItem(String key, Category category) {
    return switch (key) {
      _tableCodeCell => categoryCodeWidget(category),
      _tableNameCell => Text(category.name),
      _ => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: AppIcon.edit,
              onPressed: !loading
                  ? () {
                      editCategory(category);
                    }
                  : null,
            ),
            IconButton(
              icon: AppIcon.delete(context),
              onPressed: !loading
                  ? () {
                      deleteCategory(category);
                    }
                  : null,
            ),
          ],
        ),
    };
  }

  void editCategory(Category category) async {
    await context.push(CategoryPage.route, extra: category);
    loadData(FetchMode.refreshPage, dataPage.pageNumberOfElement(category));
  }

  Widget categoryCodeWidget(Category category) {
    return Text(
      category.code,
      textScaler: const TextScaler.linear(0.7),
      style: TextStyle(color: Theme.of(context).disabledColor),
    );
  }

  void deleteCategory(Category category) async {
    final l10n = L10n.of(context);
    final confirm = await context.confirm(
      title: l10n.categoryDelete,
      description: l10n.categoryDeleteConfirm(category.name),
    );
    if (confirm && context.mounted) {
      doDeleteCategory(category);
    }
  }

  void doDeleteCategory(Category category) async {
    try {
      await DI().get<CategoryService>().deleteCategory(code: category.code);
    } on ValidationError<CategoryError> catch (e) {
      if (e.errors.containsKey('category') && mounted) {
        context.showError(e.errors['category']!.l10n(context));
      }
    } finally {
      loadData(FetchMode.refreshPage, dataPage.pageNumberOfElement(category));
    }
  }

  void deleteSelected() async {
    final l10n = L10n.of(context);
    final confirm = await context.confirm(
      title: l10n.categoriesDelete,
      description: l10n.categoryDeleteSelectedConfirm,
    );
    if (confirm && context.mounted) {
      doDeleteSelected();
    }
  }

  void doDeleteSelected() async {
    try {
      await DI().get<CategoryService>().deleteCategories(codes: selectedCodes);
    } on ValidationError<CategoryError> catch (e) {
      if (e.errors.containsKey('category') && mounted) {
        context.showError(e.errors['category']!.l10n(context));
      }
    } finally {
      setState(() {
        selectedCodes.clear();
      });
      loadData(FetchMode.refreshPage);
    }
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(CategoryPage.route);
        loadData(FetchMode.refreshPage);
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
