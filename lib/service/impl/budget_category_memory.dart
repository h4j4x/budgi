import '../../error/validation.dart';
import '../../model/budget_category.dart';
import '../../model/budget_category_error.dart';
import '../../model/sort.dart';
import '../../util/string.dart';
import '../budget_category.dart';
import '../validator.dart';

class BudgetCategoryMemoryService implements BudgetCategoryService {
  final Validator<BudgetCategoryAmount, BudgetCategoryError>? validator;
  final categories = <String, BudgetCategory>{};
  final values = <String, Set<BudgetCategoryAmount>>{};

  BudgetCategoryMemoryService({this.validator});

  @override
  Future<BudgetCategoryAmount> saveAmount({
    String? categoryCode,
    required String categoryName,
    required DateTime fromDate,
    required DateTime toDate,
    required double amount,
  }) {
    final budgetCategoryCode = categoryCode ?? randomString(6);
    final category = _BudgetCategory(budgetCategoryCode, categoryName);
    categories[budgetCategoryCode] = category;
    final categoryAmount =
        _BudgetCategoryAmount(category, fromDate, toDate, amount);
    final errors = validator?.validate(categoryAmount);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    final amountCode = _datesCode(fromDate, toDate);
    values[amountCode] ??= <BudgetCategoryAmount>{};
    values[amountCode]!.removeWhere(
        (amount) => amount.budgetCategory.code == budgetCategoryCode);
    values[amountCode]!.add(categoryAmount);
    return Future.value(categoryAmount);
  }

  @override
  Future<List<BudgetCategoryAmount>> listAmounts({
    required DateTime fromDate,
    required DateTime toDate,
    Sort? amountSort,
  }) {
    final amountCode = _datesCode(fromDate, toDate);
    final set = values[amountCode] ?? {};
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
    required String code,
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    final amountCode = _datesCode(fromDate, toDate);
    final set = values[amountCode] ?? {};
    set.removeWhere((amount) => amount.budgetCategory.code == code);
    return Future.value();
  }

  String _datesCode(DateTime fromDate, DateTime toDate) {
    return '${fromDate.year}${fromDate.month}${fromDate.day}-${toDate.year}${toDate.month}${toDate.day}';
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
  _BudgetCategoryAmount(
      this.budgetCategory, this.fromDate, this.toDate, this.amount);

  @override
  BudgetCategory budgetCategory;

  @override
  DateTime fromDate;

  @override
  DateTime toDate;

  @override
  double amount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _BudgetCategoryAmount &&
        runtimeType == other.runtimeType &&
        budgetCategory == other.budgetCategory;
  }

  @override
  int get hashCode {
    return budgetCategory.code.hashCode;
  }
}
