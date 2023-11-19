import 'package:flutter/material.dart';

import '../di.dart';
import '../error/validation.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/budget_category_error.dart';
import '../app/router.dart';
import '../service/impl/budget_category_validator.dart';

class BudgetCategoryAmountEdit extends StatefulWidget {
  final BudgetCategoryAmount? value;
  final DateTime fromDate;
  final DateTime toDate;

  const BudgetCategoryAmountEdit({
    super.key,
    this.value,
    required this.fromDate,
    required this.toDate,
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
    final list = await DI().budgetCategoryService().listCategories(
          fromDate: widget.fromDate,
          toDate: widget.toDate,
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cancelButton(),
          saveButton(),
        ],
      ),
    ];
    return ListView.separated(
      itemBuilder: (_, index) {
        return items[index];
      },
      separatorBuilder: (_, __) {
        return const Divider(color: Colors.transparent);
      },
      itemCount: items.length,
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

  Widget cancelButton() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150, minWidth: 80),
        child: ElevatedButton(
          onPressed: saving
              ? null
              : () {
                  context.pop();
                },
          child: Text(L10n.of(context).cancelAction),
        ),
      ),
    );
  }

  Widget saveButton() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150, minWidth: 80),
        child: ElevatedButton(
          onPressed: saving ? null : onSave,
          child: Text(L10n.of(context).saveAction),
        ),
      ),
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
      await DI().budgetCategoryService().saveAmount(
            categoryCode: category!.code,
            fromDate: widget.fromDate,
            toDate: widget.toDate,
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
