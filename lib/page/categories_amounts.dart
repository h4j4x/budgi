import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/category.dart';
import '../util/function.dart';
import '../model/item_action.dart';
import '../model/period.dart';
import '../service/category.dart';
import '../widget/common/month_field.dart';
import '../widget/entity/category_amount_list.dart';
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
  final period = Period.currentMonth;

  late CrudHandler<CategoryAmount> crudHandler;

  bool loading = true;
  String? loadingMessage;

  @override
  void initState() {
    super.initState();
    crudHandler = CrudHandler(onItemAction: onItemAction);
    Future.delayed(Duration.zero, checkPreviousPeriod);
  }

  void checkPreviousPeriod() async {
    final categoryService = DI().get<CategoryService>();
    final periodChanged = await categoryService.periodHasChanged(period);
    if (periodChanged) {
      setState(() {
        loadingMessage = L10n.of(context).copyingPreviousPeriod;
      });
      await categoryService.copyPreviousPeriodAmountsInto(period);
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
        CategoryAmountList(
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
        child: MonthFieldWidget(period: period),
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
          await DI().get<CategoryService>().deleteAmount(
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
          CategoryAmountPage.route,
          extra: CategoryAmountData.fromPeriod(
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
