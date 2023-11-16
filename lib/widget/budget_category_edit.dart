import 'package:flutter/material.dart';

import '../di.dart';
import '../error/validation.dart';
import '../model/budget_category.dart';
import '../model/budget_category_error.dart';
import '../service/impl/budget_category_validator.dart';
import 'common/max_width.dart';

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
  final errors = <String, BudgetCategoryError>{};

  bool saving = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.value?.budgetCategory.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      TextField(
        controller: nameController,
        textInputAction: TextInputAction.next,
        autofocus: true,
        maxLength: 200,
        enabled: !saving,
        decoration: InputDecoration(
          labelText: 'Category name', // TODO
          hintText: 'Enter category name...', // TODO
          errorText:
              errors[BudgetCategoryAmountValidator.categoryName]?.l10n(context),
        ),
        onChanged: (_) {
          setState(() {
            errors.remove(BudgetCategoryAmountValidator.categoryName);
          });
        },
      ),
      Center(
        child: MaxWidthWidget(
          maxWidth: 150,
          child: ElevatedButton(
            onPressed: saving ? null : onSave,
            child: const Text('SAVE TODO'), // TODO
          ),
        ),
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

  void onSave() async {
    if (saving) {
      return;
    }
    setState(() {
      errors.clear();
      saving = true;
    });
    try {
      await DI().budgetCategoryService().saveAmount(
            categoryCode: widget.value?.budgetCategory.code,
            categoryName: nameController.text,
            fromDate: widget.fromDate,
            toDate: widget.toDate,
            amount: 1.0, // TODO
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
