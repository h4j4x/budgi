import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/category_amount.dart';
import '../model/error/budget.dart';
import '../model/error/validation.dart';
import '../model/item_action.dart';
import '../model/period.dart';
import '../model/table.dart';
import '../service/budget.dart';
import '../util/collection.dart';
import '../util/ui.dart';
import '../widget/common/domain_list.dart';
import '../widget/common/month_field.dart';
import '../widget/domain/budget_list.dart';
import 'budget.dart';

class BudgetsPage extends StatefulWidget {
  static const route = '/budgets';

  const BudgetsPage({super.key});

  @override
  State<StatefulWidget> createState() => _BudgetsPageState();
}

const _tableCodeCell = 'code';
const _tableNameCell = 'name';
const _tableAmountCell = 'amount';

class _BudgetsPageState extends State<BudgetsPage> {
  final list = <Budget>[];
  final selectedCodes = <String>{};

  bool initialLoading = true;
  bool loading = false;
  String? loadingMessage;
  Period period = Period.currentMonth;

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, checkPreviousPeriod);
  }

  void checkPreviousPeriod() async {
    final categoryService = DI().get<BudgetService>();
    final periodChanged = await categoryService.periodHasChanged(period);
    if (periodChanged) {
      setState(() {
        loadingMessage = L10n.of(context).copyingPreviousPeriod;
      });
      await categoryService.copyPreviousPeriodBudgetsInto(period);
      loadingMessage = null;
    }
    loadList();
  }

  void loadList() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    final newList = await DI().get<BudgetService>().listBudgets(period: period);
    list.clear();
    list.addAll(newList);
    setState(() {
      initialLoading = false;
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
    final l10n = L10n.of(context);
    return DomainList<Budget, String>.list(
      actions: actions(),
      list: list,
      tableColumns: <TableColumn>[
        TableColumn(key: _tableCodeCell, label: l10n.code, widthPercent: 10),
        TableColumn(key: _tableNameCell, label: l10n.categoryName),
        TableColumn(key: _tableAmountCell, label: l10n.budgetAmount, widthPercent: 10),
        TableColumn(key: 'icons', label: '', fixedWidth: 100, alignment: Alignment.center),
      ],
      initialLoading: initialLoading,
      loadingNextPage: loading,
      itemBuilder: listItem,
      itemCellBuilder: cellItem,
      selectedKeys: selectedCodes,
      onKeySelect: (code, selected) {
        if (selected) {
          selectedCodes.add(code);
        } else {
          selectedCodes.remove(code);
        }
        setState(() {});
      },
      keyOf: (budget) {
        return budget.category.code;
      },
    );
  }

  Widget listItem(BuildContext context, Budget item, _, bool selected) {
    return ListTile(
      selected: selected,
      leading: selected ? AppIcon.selected : null,
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
          if (confirm && context.mounted) {
            onItemAction(context, item, ItemAction.delete);
          }
        },
      ),
      onTap: () {
        onItemAction(context, item, ItemAction.select);
      },
      onLongPress: !loading
          ? () {
              setState(() {
                selectedCodes.xAdd(item.category.code);
              });
            }
          : null,
    );
  }

  Widget body1() {
    if (loading) {
      return loadingBody();
    }
    return CustomScrollView(
      slivers: [
        toolbar(),
        BudgetList(
          list: list,
          enabled: !loading,
          onItemAction: onItemAction,
        ),
      ],
    );
  }

  Widget toolbar() {
    return SliverAppBar(
      toolbarHeight: kToolbarHeight + 16,
      title: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: MonthFieldWidget(period: period),
      ),
      actions: [
        IconButton(
          onPressed: loadList,
          icon: AppIcon.reload,
        ),
      ],
    );
  }

  Widget loadingBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(),
          if (loadingMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(loadingMessage!),
            ),
        ],
      ),
    );
  }

  void onItemAction(
    BuildContext context,
    Budget item,
    ItemAction action,
  ) async {
    switch (action) {
      case ItemAction.select:
        {
          await context.push(
            BudgetPage.route,
            extra: BudgetData.fromPeriod(
              budget: item,
              period: period,
            ),
          );
          break;
        }
      case ItemAction.delete:
        {
          await DI().get<BudgetService>().deleteBudget(
                category: item.category,
                period: period,
              );
          break;
        }
    }
    loadList();
  }

  Widget cellItem(String key, Budget budget) {
    return switch (key) {
      _tableCodeCell => categoryCodeWidget(budget),
      _tableNameCell => Text(budget.category.name),
      _ => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: AppIcon.edit,
              onPressed: !loading ? () => editBudget(budget) : null,
            ),
            IconButton(
              icon: AppIcon.delete(context),
              onPressed: !loading ? () => deleteBudget(budget) : null,
            ),
          ],
        ),
    };
  }

  void editBudget(Budget budget) async {
    await context.push(
      BudgetPage.route,
      extra: BudgetData.fromPeriod(
        budget: budget,
        period: period,
      ),
    );
    loadList();
  }

  Widget categoryCodeWidget(Budget budget) {
    return Text(
      budget.category.code,
      textScaler: const TextScaler.linear(0.7),
      style: TextStyle(color: Theme.of(context).disabledColor),
    );
  }

  void deleteBudget(Budget budget) async {
    final l10n = L10n.of(context);
    final confirm = await context.confirm(
      title: l10n.categoryDelete,
      description: l10n.budgetDeleteConfirm(budget.category.name),
    );
    if (confirm && context.mounted) {
      doDeleteBudget(budget);
    }
  }

  void doDeleteBudget(Budget budget) async {
    try {
      await DI().get<BudgetService>().deleteBudget(
            category: budget.category,
            period: period,
          );
    } on ValidationError<BudgetError> catch (e) {
      if (e.errors.containsKey('budget') && mounted) {
        context.showError(e.errors['budget']!.l10n(context));
      }
    } finally {
      loadList();
    }
  }

  void deleteSelected() async {
    final l10n = L10n.of(context);
    final confirm = await context.confirm(
      title: l10n.budgetsDelete,
      description: l10n.budgetDeleteSelectedConfirm,
    );
    if (confirm && context.mounted) {
      doDeleteSelected();
    }
  }

  void doDeleteSelected() async {
    try {
      await DI().get<BudgetService>().deleteBudgets(codes: selectedCodes);
    } on ValidationError<BudgetError> catch (e) {
      if (e.errors.containsKey('budget') && mounted) {
        context.showError(e.errors['budget']!.l10n(context));
      }
    } finally {
      setState(() {
        selectedCodes.clear();
      });
      loadList();
    }
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(
          BudgetPage.route,
          extra: BudgetData.fromPeriod(
            period: period,
          ),
        );
        loadList();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
