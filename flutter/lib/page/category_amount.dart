import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../model/domain/category_amount.dart';
import '../model/period.dart';
import '../widget/entity/category_amount_edit.dart';

class CategoryAmountPage extends StatelessWidget {
  static const route = '/category-amount';

  final CategoryAmount? value;
  final Period period;

  const CategoryAmountPage({
    super.key,
    this.value,
    required this.period,
  });

  CategoryAmountPage.data(CategoryAmountData data, {super.key})
      : value = data.amount,
        period = data;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final action = value != null ? l10n.editAction : l10n.createAction;
    return Scaffold(
      appBar: AppBar(
        title: Text('$action ${l10n.budgetAmount.toLowerCase()}'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: CategoryAmountEdit(
          value: value,
          period: period,
        ),
      ),
    );
  }
}
