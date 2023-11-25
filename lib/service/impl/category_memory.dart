import '../../di.dart';
import '../../error/validation.dart';
import '../../model/category.dart';
import '../../model/category_error.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../model/transaction.dart';
import '../../util/string.dart';
import '../category.dart';
import '../transaction.dart';
import '../validator.dart';

class CategoryMemoryService implements CategoryService {
  final Validator<Category, CategoryError>? categoryValidator;
  final Validator<CategoryAmount, CategoryError>? amountValidator;

  final _categories = <String, Category>{};
  final _values = <String, Set<CategoryAmount>>{};
  final _periods = <String>[];

  CategoryMemoryService({
    this.categoryValidator,
    this.amountValidator,
  });

  @override
  Future<Category> saveCategory({
    String? code,
    required String name,
  }) {
    final categoryCode = code ?? randomString(6);
    final category = _Category(categoryCode, name);
    final errors = categoryValidator?.validate(category);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    _categories[categoryCode] = category;
    return Future.value(category);
  }

  @override
  Future<List<Category>> listCategories({
    bool withAmount = false,
    Period? period,
  }) {
    final list = _categories.values.toList();
    if (period != null) {
      final amountsCategories =
          (_values[period.toString()] ?? <CategoryAmount>{}).map((amount) => amount.category.code).toList();
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
  Future<CategoryAmount> saveAmount({
    required String categoryCode,
    String? amountCode,
    required Period period,
    required double amount,
  }) {
    _saveLastUsed(period);

    final category = _categories[categoryCode];
    if (category == null) {
      throw ValidationError({
        'category': CategoryError.invalidCategory,
      });
    }
    final categoryAmount = _CategoryAmount(category, period, amount);
    final errors = amountValidator?.validate(categoryAmount);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    final periodKey = period.toString();
    _values[periodKey] ??= <CategoryAmount>{};
    _values[periodKey]!.removeWhere((amount) => amount.category.code == category.code);
    _values[periodKey]!.add(categoryAmount);
    return Future.value(categoryAmount);
  }

  @override
  Future<List<CategoryAmount>> listAmounts({
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
      _values[periodKey] = <CategoryAmount>{};
      for (var categoryAmount in _values[previousPeriodKey]!) {
        _values[periodKey]!.add(categoryAmount.copyWith(period: period));
      }
    }
    return Future.value();
  }

  @override
  Future<Map<CategoryAmount, double>> categoriesTransactionsTotal({
    required Period period,
    bool expensesTransactions = true,
    bool showZeroTotal = false,
  }) async {
    final transactionTypes = TransactionType.values.where((type) {
      if (expensesTransactions) {
        return !type.isIncome;
      }
      return type.isIncome;
    }).toList();
    final transactions = await DI().get<TransactionService>().listTransactions(
          transactionTypes: transactionTypes,
          period: period,
          dateTimeSort: Sort.asc,
        );
    final map = <CategoryAmount, double>{};
    final amounts = _values[period.toString()] ?? {};
    for (var transaction in transactions) {
      final categoryAmount = amounts.where((amount) => amount.category == transaction.category).toList();
      if (categoryAmount.length == 1) {
        map[categoryAmount.first] = (map[categoryAmount.first] ?? 0) + transaction.signedAmount;
      }
    }
    if (showZeroTotal) {
      for (var categoryAmount in amounts) {
        map[categoryAmount] ??= 0;
      }
    }
    return Future.delayed(const Duration(seconds: 1), () {
      return map;
    });
  }
}

class _Category implements Category {
  _Category(this.code, this.name);

  @override
  String code;

  @override
  String name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _Category && runtimeType == other.runtimeType && code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}

class _CategoryAmount implements CategoryAmount {
  _CategoryAmount(this.category, this.period, this.amount);

  @override
  Category category;

  @override
  Period period;

  @override
  double amount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _CategoryAmount && runtimeType == other.runtimeType && category == other.category;
  }

  @override
  int get hashCode {
    return category.code.hashCode;
  }

  @override
  CategoryAmount copyWith({required Period period}) {
    return _CategoryAmount(category, period, amount);
  }
}
