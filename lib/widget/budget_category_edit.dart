import 'package:flutter/material.dart';

import '../di.dart';
import '../error/validation.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/budget_category_error.dart';
import '../service/impl/budget_category_validator.dart';

class BudgetCategoryEdit extends StatefulWidget {
  final BudgetCategoryAmount? value;
  final DateTime fromDate;
  final DateTime toDate;

  const BudgetCategoryEdit({
    super.key,
    this.value,
    required this.fromDate,
    required this.toDate,
  });

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoryEditState();
  }
}

class _BudgetCategoryEditState extends State<BudgetCategoryEdit> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final amountFocus = FocusNode();
  final errors = <String, BudgetCategoryError>{};

  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      nameController.text = widget.value!.budgetCategory.name;
      amountController.text =
          widget.value!.amount.toStringAsFixed(2).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      categoryNameField(),
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

  Widget categoryNameField() {
    final l10n = L10n.of(context);
    return TextField(
      controller: nameController,
      textInputAction: TextInputAction.next,
      autofocus: true,
      maxLength: 200,
      enabled: !saving,
      decoration: InputDecoration(
        labelText: l10n.categoryName,
        hintText: l10n.categoryNameHint,
        errorText:
            errors[BudgetCategoryAmountValidator.categoryName]?.l10n(context),
      ),
      onChanged: (_) {
        setState(() {
          errors.remove(BudgetCategoryAmountValidator.categoryName);
        });
      },
      onSubmitted: (_) {
        amountFocus.requestFocus();
      },
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
                  Navigator.of(context).pop();
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
    setState(() {
      errors.clear();
      saving = true;
    });
    try {
      final amount = double.tryParse(amountController.text) ?? -1;
      await DI().budgetCategoryService().saveAmount(
            categoryCode: widget.value?.budgetCategory.code,
            categoryName: nameController.text,
            fromDate: widget.fromDate,
            toDate: widget.toDate,
            amount: amount,
          );
      if (mounted) {
        Navigator.of(context).pop();
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
