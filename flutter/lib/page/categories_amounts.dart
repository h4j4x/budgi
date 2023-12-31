import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/category_amount.dart';
import '../model/item_action.dart';
import '../model/period.dart';
import '../service/category_amount.dart';
import '../widget/common/month_field.dart';
import '../widget/domain/category_amount_list.dart';
import 'category_amount.dart';

class CategoriesAmountsPage extends StatefulWidget {
  static const route = '/categories-amounts';

  const CategoriesAmountsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CategoriesAmountsPageState();
  }
}

class _CategoriesAmountsPageState extends State<CategoriesAmountsPage> {
  final list = <CategoryAmount>[];

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
    final categoryService = DI().get<CategoryAmountService>();
    final periodChanged = await categoryService.periodHasChanged(period);
    if (periodChanged) {
      setState(() {
        loadingMessage = L10n.of(context).copyingPreviousPeriod;
      });
      await categoryService.copyPreviousPeriodAmountsInto(period);
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
    final newList =
        await DI().get<CategoryAmountService>().listAmounts(period: period);
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
        CategoryAmountList(
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
    CategoryAmount item,
    ItemAction action,
  ) async {
    switch (action) {
      case ItemAction.select:
        {
          await context.push(
            CategoryAmountPage.route,
            extra: CategoryAmountData.fromPeriod(
              amount: item,
              period: period,
            ),
          );
          break;
        }
      case ItemAction.delete:
        {
          await DI().get<CategoryAmountService>().deleteAmount(
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
          CategoryAmountPage.route,
          extra: CategoryAmountData.fromPeriod(
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
