import '../../error/validation.dart';
import '../../model/budget_category.dart';
import '../../model/budget_category_error.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../util/string.dart';
import '../budget_category.dart';
import '../validator.dart';

class BudgetCategoryMemoryService implements BudgetCategoryService {
  final Validator<BudgetCategory, BudgetCategoryError>? categoryValidator;
  final Validator<BudgetCategoryAmount, BudgetCategoryError>? amountValidator;
  final categories = <String, BudgetCategory>{};
  final values = <String, Set<BudgetCategoryAmount>>{};

  BudgetCategoryMemoryService({
    this.categoryValidator,
    this.amountValidator,
  });

  @override
  Future<BudgetCategory> saveCategory({
    String? code,
    required String name,
  }) {
    final budgetCategoryCode = code ?? randomString(6);
    final category = _BudgetCategory(budgetCategoryCode, name);
    final errors = categoryValidator?.validate(category);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    categories[budgetCategoryCode] = category;
    return Future.value(category);
  }

  @override
  Future<List<BudgetCategory>> listCategories({
    bool withAmount = false,
    Period? period,
  }) {
    final list = categories.values.toList();
    if (period != null) {
      final datesCode = _datesCode(period);
      final amountsCategories = (values[datesCode] ?? <BudgetCategoryAmount>{})
          .map((amount) => amount.category.code)
          .toList();
      list.removeWhere((category) {
        final match = amountsCategories.contains(category.code);
        if (withAmount) {
          return !match;
        }
        return match;
      });
    }
    return Future.value(list);
  }

  @override
  Future<void> deleteCategory({
    required String code,
  }) {
    categories.remove(code);
    return Future.value();
  }

  @override
  Future<BudgetCategoryAmount> saveAmount({
    required String categoryCode,
    String? amountCode,
    required Period period,
    required double amount,
  }) {
    final category = categories[categoryCode];
    if (category == null) {
      throw ValidationError({
        'category': BudgetCategoryError.invalidCategory,
      });
    }
    final categoryAmount = _BudgetCategoryAmount(category, period, amount);
    final errors = amountValidator?.validate(categoryAmount);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    final datesCode = _datesCode(period);
    values[datesCode] ??= <BudgetCategoryAmount>{};
    values[datesCode]!
        .removeWhere((amount) => amount.category.code == category.code);
    values[datesCode]!.add(categoryAmount);
    return Future.value(categoryAmount);
  }

  @override
  Future<List<BudgetCategoryAmount>> listAmounts({
    required Period period,
    Sort? amountSort,
  }) {
    final datesCode = _datesCode(period);
    final set = values[datesCode] ?? {};
    return Future.value(set.toList()
      ..sort(
        (value1, value2) {
          if (amountSort == Sort.asc) {
            return value1.amount.compareTo(value2.amount);
          }
          if (amountSort == Sort.desc) {
            return value2.amount.compareTo(value1.amount);
          }
          return 0;
        },
      ));
  }

  @override
  Future<void> deleteAmount({
    required String categoryCode,
    required Period period,
  }) {
    final datesCode = _datesCode(period);
    final set = values[datesCode] ?? {};
    set.removeWhere((amount) => amount.category.code == categoryCode);
    return Future.value();
  }

  String _datesCode(Period period) {
    final from = '${period.from.year}${period.from.month}${period.from.day}';
    final to = '${period.to.year}${period.to.month}${period.to.day}';
    return '$from-$to';
  }
}

class _BudgetCategory implements BudgetCategory {
  _BudgetCategory(this.code, this.name);

  @override
  String code;

  @override
  String name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _BudgetCategory &&
        runtimeType == other.runtimeType &&
        code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}

class _BudgetCategoryAmount implements BudgetCategoryAmount {
  _BudgetCategoryAmount(this.category, this.period, this.amount);

  @override
  BudgetCategory category;

  @override
  Period period;

  @override
  double amount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _BudgetCategoryAmount &&
        runtimeType == other.runtimeType &&
        category == other.category;
  }

  @override
  int get hashCode {
    return category.code.hashCode;
  }
}
