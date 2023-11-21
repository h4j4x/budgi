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

  final _categories = <String, BudgetCategory>{};
  final _values = <String, Set<BudgetCategoryAmount>>{};
  final _periods = <String>[];

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

    _categories[budgetCategoryCode] = category;
    return Future.value(category);
  }

  @override
  Future<List<BudgetCategory>> listCategories({
    bool withAmount = false,
    Period? period,
  }) {
    final list = _categories.values.toList();
    if (period != null) {
      final amountsCategories =
          (_values[period.toString()] ?? <BudgetCategoryAmount>{})
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
    _categories.remove(code);
    return Future.value();
  }

  @override
  Future<BudgetCategoryAmount> saveAmount({
    required String categoryCode,
    String? amountCode,
    required Period period,
    required double amount,
  }) {
    _saveLastUsed(period);

    final category = _categories[categoryCode];
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

    final periodKey = period.toString();
    _values[periodKey] ??= <BudgetCategoryAmount>{};
    _values[periodKey]!
        .removeWhere((amount) => amount.category.code == category.code);
    _values[periodKey]!.add(categoryAmount);
    return Future.value(categoryAmount);
  }

  @override
  Future<List<BudgetCategoryAmount>> listAmounts({
    required Period period,
    Sort? amountSort,
  }) {
    _saveLastUsed(period);

    final set = _values[period.toString()] ?? {};
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
    _saveLastUsed(period);

    final set = _values[period.toString()] ?? {};
    set.removeWhere((amount) => amount.category.code == categoryCode);
    return Future.value();
  }

  void _saveLastUsed(Period period) {
    final periodKey = period.toString();
    if (!_periods.contains(periodKey)) {
      _periods.add(periodKey);
    }
  }

  @override
  Future<bool> periodHasChanged(Period period) {
    if (_periods.isNotEmpty) {
      final periodKey = period.toString();
      return Future.value(!_periods.contains(periodKey));
    }
    return Future.value(false);
  }

  @override
  Future copyPreviousPeriodAmountsInto(Period period) {
    if (_periods.isNotEmpty) {
      final previousPeriodKey = _periods.last;
      final periodKey = period.toString();
      _values[periodKey] = <BudgetCategoryAmount>{};
      for (var categoryAmount in _values[previousPeriodKey]!) {
        _values[periodKey]!.add(categoryAmount.copyWith(period: period));
      }
    }
    return Future.value();
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

  @override
  BudgetCategoryAmount copyWith({required Period period}) {
    return _BudgetCategoryAmount(category, period, amount);
  }
}
