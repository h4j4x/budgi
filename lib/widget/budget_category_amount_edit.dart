import 'package:flutter/material.dart';

import '../app/router.dart';
import '../di.dart';
import '../error/validation.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/budget_category_error.dart';
import '../model/period.dart';
import '../service/budget_category.dart';
import '../service/impl/budget_category_validator.dart';
import 'common/form_toolbar.dart';

class BudgetCategoryAmountEdit extends StatefulWidget {
  final BudgetCategoryAmount? value;
  final Period period;

  const BudgetCategoryAmountEdit({
    super.key,
    this.value,
    required this.period,
  });

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoryAmountEditState();
  }
}

class _BudgetCategoryAmountEditState extends State<BudgetCategoryAmountEdit> {
  final amountController = TextEditingController();
  final amountFocus = FocusNode();
  final errors = <String, BudgetCategoryError>{};

  bool saving = false;
  List<BudgetCategory>? categories;
  BudgetCategory? category;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      amountController.text =
          widget.value!.amount.toStringAsFixed(2).toString();
      categories = <BudgetCategory>[widget.value!.category];
      category = widget.value!.category;
    } else {
      Future.delayed(Duration.zero, loadCategories);
    }
  }

  void loadCategories() async {
    final list = await DI().get<BudgetCategoryService>().listCategories(
          period: widget.period,
        );
    setState(() {
      categories = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      categoryField(),
      amountField(),
      const SizedBox(height: 24),
      FormToolbar(enabled: !saving, onSave: onSave),
    ];
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.separated(
          itemBuilder: (_, index) {
            return items[index];
          },
          separatorBuilder: (_, __) {
            return const Divider(color: Colors.transparent);
          },
          itemCount: items.length,
        ),
      ),
    );
  }

  Widget categoryField() {
    return DropdownButtonFormField<BudgetCategory>(
      items: (categories ?? []).map(categoryOption).toList(),
      value: category,
      decoration: InputDecoration(
        hintText: L10n.of(context).budgetAmountCategoryHint,
        errorText:
            errors[BudgetCategoryAmountValidator.category]?.l10n(context),
      ),
      isExpanded: true,
      onChanged: widget.value == null
          ? (selectedCategory) {
              if (selectedCategory != null) {
                setState(() {
                  category = selectedCategory;
                });
              }
            }
          : null,
    );
  }

  DropdownMenuItem<BudgetCategory> categoryOption(BudgetCategory value) {
    return DropdownMenuItem<BudgetCategory>(
      value: value,
      enabled: value != category,
      child: Text(value.name),
    );
  }

  Widget amountField() {
    final l10n = L10n.of(context);
    return TextField(
      controller: amountController,
      textInputAction: TextInputAction.next,
      enabled: !saving,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      focusNode: amountFocus,
      decoration: InputDecoration(
        labelText: l10n.budgetAmount,
        hintText: l10n.budgetAmountHint,
        errorText: errors[BudgetCategoryAmountValidator.amount]?.l10n(context),
      ),
      onChanged: (_) {
        setState(() {
          errors.remove(BudgetCategoryAmountValidator.amount);
        });
      },
    );
  }

  void onSave() async {
    if (saving) {
      return;
    }

    if (category == null) {
      setState(() {
        errors[BudgetCategoryAmountValidator.category] =
            BudgetCategoryError.invalidCategory;
      });
      return;
    }

    setState(() {
      errors.clear();
      saving = true;
    });
    try {
      final amount = double.tryParse(amountController.text) ?? -1;
      await DI().get<BudgetCategoryService>().saveAmount(
            categoryCode: category!.code,
            period: widget.period,
            amount: amount,
          );
      if (mounted) {
        context.pop();
      }
    } on ValidationError<BudgetCategoryError> catch (e) {
      errors.addAll(e.errors);
    } finally {
      setState(() {
        saving = false;
      });
    }
  }
}
