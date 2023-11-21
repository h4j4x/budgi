import 'package:flutter/material.dart';

import '../di.dart';
import '../error/validation.dart';
import '../l10n/l10n.dart';
import '../model/budget_category.dart';
import '../model/budget_category_error.dart';
import '../app/router.dart';
import '../service/impl/budget_category_validator.dart';

class BudgetCategoryEdit extends StatefulWidget {
  final BudgetCategory? value;

  const BudgetCategoryEdit({
    super.key,
    this.value,
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
    if (widget.value != null) {
      nameController.text = widget.value!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      categoryNameField(),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cancelButton(),
          saveButton(),
        ],
      ),
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
        errorText: errors[BudgetCategoryValidator.name]?.l10n(context),
      ),
      onChanged: (_) {
        setState(() {
          errors.remove(BudgetCategoryValidator.name);
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
    setState(() {
      errors.clear();
      saving = true;
    });
    try {
      await DI().budgetCategoryService().saveCategory(
            code: widget.value?.code,
            name: nameController.text,
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
