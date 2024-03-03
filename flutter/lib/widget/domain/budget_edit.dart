import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/category.dart';
import '../../model/domain/category_amount.dart';
import '../../model/error/category.dart';
import '../../model/error/validation.dart';
import '../../model/period.dart';
import '../../service/category.dart';
import '../../service/budget.dart';
import '../../service/impl/category_amount_validator.dart';
import '../../service/spring/http_client.dart';
import '../../util/ui.dart';
import '../common/form_toolbar.dart';
import 'category_select.dart';

class BudgetEdit extends StatefulWidget {
  final Budget? value;
  final Period period;

  const BudgetEdit({
    super.key,
    this.value,
    required this.period,
  });

  @override
  State<StatefulWidget> createState() {
    return _BudgetEditState();
  }
}

class _BudgetEditState extends State<BudgetEdit> {
  final amountController = TextEditingController();
  final amountFocus = FocusNode();
  final errors = <String, CategoryError>{};

  bool saving = false;
  List<Category>? categories;
  Category? category;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      amountController.text =
          widget.value!.amount.toStringAsFixed(2).toString();
      categories = <Category>[widget.value!.category];
      category = widget.value!.category;
    } else {
      Future.delayed(Duration.zero, loadCategories);
    }
  }

  void loadCategories() async {
    final list = await DI().get<CategoryService>().listCategories(
          pageSize: 1000, // TODO: select with filter & pagination
        );
    setState(() {
      categories = list.content;
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
    return CategorySelect(
      list: categories,
      value: category,
      enabled: widget.value == null,
      onChanged: (value) {
        setState(() {
          errors.remove(BudgetValidator.category);
          category = value;
        });
      },
      hintText: L10n.of(context).budgetAmountCategoryHint,
      errorText: errors[BudgetValidator.category]?.l10n(context),
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
      textAlign: TextAlign.end,
      decoration: InputDecoration(
        labelText: l10n.budgetAmount,
        hintText: l10n.budgetAmountHint,
        errorText: errors[BudgetValidator.amount]?.l10n(context),
      ),
      onChanged: (_) {
        setState(() {
          errors.remove(BudgetValidator.amount);
        });
      },
      onSubmitted: (_) {
        onSave();
      },
    );
  }

  void onSave() async {
    if (saving) {
      return;
    }

    if (category == null) {
      setState(() {
        errors[BudgetValidator.category] = CategoryError.invalidCategory;
      });
      return;
    }

    setState(() {
      errors.clear();
      saving = true;
    });
    try {
      final amount = double.tryParse(amountController.text) ?? -1;
      await DI().get<BudgetService>().saveBudget(
            category: category!,
            period: widget.period,
            amount: amount,
          );
      if (mounted) {
        context.pop();
      }
    } on ValidationError<CategoryError> catch (e) {
      errors.addAll(e.errors);
    } on HttpError catch (e) {
      if (mounted) {
        context.showError(e.l10n(context));
      }
    } finally {
      setState(() {
        saving = false;
      });
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
