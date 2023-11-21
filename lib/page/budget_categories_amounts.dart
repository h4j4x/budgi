import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/crud_handler.dart';
import '../model/item_action.dart';
import '../model/period.dart';
import '../service/budget_category.dart';
import '../util/datetime.dart';
import '../widget/budget_category_amount_list.dart';
import 'budget_category_amount.dart';

class BudgetCategoriesAmountsPage extends StatefulWidget {
  static const route = '/categories-amounts';

  const BudgetCategoriesAmountsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoriesAmountsPageState();
  }
}

class _BudgetCategoriesAmountsPageState
    extends State<BudgetCategoriesAmountsPage> {
  final periodController = TextEditingController();
  final period = Period.currentMonth;

  late CrudHandler<BudgetCategoryAmount> crudHandler;

  bool loading = true;
  String? loadingMessage;

  @override
  void initState() {
    super.initState();
    crudHandler = CrudHandler(onItemAction: onItemAction);
    Future.delayed(Duration.zero, () {
      periodController.text = formatDateTimePeriod(
        context,
        period: period,
      );
      checkPreviousPeriod();
    });
  }

  void checkPreviousPeriod() async {
    final budgetCategoryService = DI().get<BudgetCategoryService>();
    final periodChanged = await budgetCategoryService.periodHasChanged(period);
    if (periodChanged) {
      setState(() {
        loadingMessage = L10n.of(context).copyingPreviousPeriod;
      });
      await budgetCategoryService.copyPreviousPeriodAmountsInto(period);
    }
    setState(() {
      loading = false;
      loadingMessage = null;
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
        BudgetCategoryAmountList(
          crudHandler: crudHandler,
          period: period,
        ),
      ],
    );
  }

  Widget toolbar() {
    return SliverAppBar(
      toolbarHeight: kToolbarHeight + 16,
      title: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: TextField(
          controller: periodController,
          readOnly: true,
          enabled: false,
        ),
      ),
      actions: [
        IconButton(
          onPressed: crudHandler.reload,
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
    BudgetCategoryAmount item,
    ItemAction action,
  ) async {
    switch (action) {
      case ItemAction.select:
        {
          await context.push(
            BudgetCategoryAmountPage.route,
            extra: BudgetCategoryAmountData.fromPeriod(
              amount: item,
              period: period,
            ),
          );
          break;
        }
      case ItemAction.delete:
        {
          await DI().get<BudgetCategoryService>().deleteAmount(
                categoryCode: item.category.code,
                period: period,
              );
          break;
        }
    }
    crudHandler.reload();
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(
          BudgetCategoryAmountPage.route,
          extra: BudgetCategoryAmountData.fromPeriod(
            period: period,
          ),
        );
        crudHandler.reload();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
