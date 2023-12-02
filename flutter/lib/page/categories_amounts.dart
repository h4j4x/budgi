import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/icon.dart';
import '../app/router.dart';
import '../di.dart';
import '../l10n/l10n.dart';
import '../model/domain/category_amount.dart';
import '../model/item_action.dart';
import '../model/period.dart';
import '../model/state/crud.dart';
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

const _periodKey = 'period';

class _CategoriesAmountsPageState extends State<CategoriesAmountsPage> {
  bool loading = true;
  String? loadingMessage;

  CrudState<CategoryAmount> get state {
    return context.watch<CrudState<CategoryAmount>>();
  }

  Period get period {
    final value = state.filters[_periodKey];
    return (value as Period?) ?? Period.currentMonth;
  }

  Future<List<CategoryAmount>> load() async {
    return DI().get<CategoryAmountService>().listAmounts(period: period);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      state.load();
      checkPreviousPeriod();
    });
  }

  void checkPreviousPeriod() async {
    final categoryService = DI().get<CategoryAmountService>();
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
    return ChangeNotifierProvider<CrudState<CategoryAmount>>(
      create: (_) {
        return CrudState<CategoryAmount>(loader: load, filters: {
          _periodKey: Period.currentMonth,
        });
      },
      child: Scaffold(
        body: body(),
        floatingActionButton: addButton(),
      ),
    );
  }

  Widget body() {
    if (loading || state.loading) {
      return loadingBody();
    }
    return CustomScrollView(
      slivers: [
        toolbar(),
        CategoryAmountList(onItemAction: onItemAction),
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
          onPressed: state.load,
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
    state.load();
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
        state.load();
      },
      tooltip: L10n.of(context).addAction,
      child: AppIcon.add,
    );
  }
}
