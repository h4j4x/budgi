import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../app/router.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/category.dart';
import '../../model/domain/category_amount.dart';
import '../../model/error/category.dart';
import '../../model/error/validation.dart';
import '../../model/period.dart';
import '../../service/category.dart';
import '../../service/category_amount.dart';
import '../../service/impl/category_amount_validator.dart';
import '../common/form_toolbar.dart';
import '../common/select_field.dart';

class CategoryAmountEdit extends StatefulWidget {
  final CategoryAmount? value;
  final Period period;

  const CategoryAmountEdit({
    super.key,
    this.value,
    required this.period,
  });

  @override
  State<StatefulWidget> createState() {
    return _CategoryAmountEditState();
  }
}

class _CategoryAmountEditState extends State<CategoryAmountEdit> {
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
      amountController.text = widget.value!.amount.toStringAsFixed(2).toString();
      categories = <Category>[widget.value!.category];
      category = widget.value!.category;
    } else {
      Future.delayed(Duration.zero, loadCategories);
    }
  }

  void loadCategories() async {
    final list = await DI().get<CategoryService>().listCategories(
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
    return SelectField<Category>(
      items: categories ?? [],
      itemBuilder: (context, value) {
        return Text(value.name);
      },
      onChanged: widget.value == null
          ? (value) {
              setState(() {
                errors.remove(CategoryAmountValidator.category);
                category = value;
              });
            }
          : null,
      selectedValue: category,
      icon: categories == null ? AppIcon.loading : AppIcon.category,
      hintText: L10n.of(context).budgetAmountCategoryHint,
      errorText: errors[CategoryAmountValidator.category]?.l10n(context),
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
        errorText: errors[CategoryAmountValidator.amount]?.l10n(context),
      ),
      onChanged: (_) {
        setState(() {
          errors.remove(CategoryAmountValidator.amount);
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
        errors[CategoryAmountValidator.category] = CategoryError.invalidCategory;
      });
      return;
    }

    setState(() {
      errors.clear();
      saving = true;
    });
    try {
      final amount = double.tryParse(amountController.text) ?? -1;
      await DI().get<CategoryAmountService>().saveAmount(
            category: category!,
            period: widget.period,
            amount: amount,
          );
      if (mounted) {
        context.pop();
      }
    } on ValidationError<CategoryError> catch (e) {
      errors.addAll(e.errors);
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
