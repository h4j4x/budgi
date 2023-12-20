import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/category_amount.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../service/category_amount.dart';
import '../common/month_field.dart';
import '../common/responsive.dart';
import '../common/sort_field.dart';

class CategoriesExpenses extends StatefulWidget {
  const CategoriesExpenses({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CategoriesExpensesState();
  }
}

class _CategoriesExpensesState extends State<CategoriesExpenses> {
  final amounts = <CategoryAmount>[];
  final amountsMap = <CategoryAmount, double>{};

  bool loading = false;

  Period period = Period.currentMonth;
  Sort amountSort = Sort.desc;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, loadMap);
  }

  void loadMap() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    final values = await DI().get<CategoryAmountService>().categoriesTransactionsTotal(period: period);
    amounts.clear();
    amounts.addAll(values.keys);
    amountsMap.clear();
    amountsMap.addAll(values);
    sortKeys();
  }

  void sortKeys() {
    amounts.sort((w1, w2) {
      if (amountSort == Sort.asc) {
        return amountsMap[w1]!.compareTo(amountsMap[w2]!);
      }
      return amountsMap[w2]!.compareTo(amountsMap[w1]!);
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(mobile: body(true), desktop: body(false));
  }

  Widget body(bool mobileSize) {
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        toolbar(mobileSize),
        list(),
      ],
    );
  }

  Widget toolbar(bool mobileSize) {
    return SliverAppBar(
      toolbarHeight: kToolbarHeight + 16,
      title: MonthFieldWidget(
        period: period,
        onChanged: !loading
            ? (value) {
                period = value;
                loadMap();
              }
            : null,
      ),
      actions: [
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.only(right: 4),
          child: SortField(
              mobileSize: mobileSize,
              title: L10n.of(context).sortByAmount,
              value: amountSort,
              onChanged: !loading && amounts.isNotEmpty
                  ? (value) {
                      amountSort = value;
                      sortKeys();
                    }
                  : null),
        ),
        IconButton(
          onPressed: !loading ? loadMap : null,
          icon: AppIcon.reload,
        ),
      ],
    );
  }

  Widget list() {
    return SliverList.separated(
      itemBuilder: (_, index) {
        if (loading || amounts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: loading ? const CircularProgressIndicator.adaptive() : Text(L10n.of(context).nothingHere),
            ),
          );
        }
        return listItem(amounts[index]);
      },
      separatorBuilder: (_, __) {
        return const Divider();
      },
      itemCount: amounts.isNotEmpty && !loading ? amounts.length : 1,
    );
  }

  Widget listItem(CategoryAmount item) {
    final budget = item.amount;
    final amount = (amountsMap[item] ?? 0).abs();
    final diff = budget - amount;
    return ListTile(
      title: Text(item.category.name),
      subtitle: Text('\$${budget.toStringAsFixed(2)} - \$${amount.toStringAsFixed(2)} = \$${diff.toStringAsFixed(2)}'),
    );
  }
}
