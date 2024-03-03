import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/category_amount.dart';
import '../model/item_action.dart';
import '../model/period.dart';
import '../service/budget.dart';
import '../widget/common/month_field.dart';
import '../widget/domain/budget_list.dart';
import 'budget.dart';

class BudgetsPage extends StatefulWidget {
  static const route = '/budgets';

  const BudgetsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BudgetsPageState();
  }
}

class _BudgetsPageState extends State<BudgetsPage> {
  final list = <Budget>[];

  bool loading = false;
  String? loadingMessage;
  Period period = Period.currentMonth;

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, checkPreviousPeriod);
  }

  void checkPreviousPeriod() async {
    setState(() {
      loading = true;
    });
    final categoryService = DI().get<BudgetService>();
    final periodChanged = await categoryService.periodHasChanged(period);
    if (periodChanged) {
      setState(() {
        loadingMessage = L10n.of(context).copyingPreviousPeriod;
      });
      await categoryService.copyPreviousPeriodBudgetsInto(period);
      loadingMessage = null;
    }
    loading = false;
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
