import '../../di.dart';
import '../../model/data_page.dart';
import '../../model/domain/category.dart';
import '../../model/domain/category_amount.dart';
import '../../model/domain/transaction.dart';
import '../../model/error/budget.dart';
import '../../model/error/category.dart';
import '../../model/error/validation.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../util/string.dart';
import '../category.dart';
import '../budget.dart';
import '../transaction.dart';
import '../validator.dart';

class CategoryMemoryService implements CategoryService, BudgetService {
  final Validator<Category, CategoryError>? categoryValidator;
  final Validator<Budget, BudgetError>? budgetValidator;

  final _categories = <String, Category>{};
  final _values = <String, Set<Budget>>{};
  final _periods = <String>[];

  CategoryMemoryService({
    this.categoryValidator,
    this.budgetValidator,
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
  Future<DataPage<Category>> listCategories({
    Set<String>? includingCodes,
    Set<String>? excludingCodes,
    int? page,
    int? pageSize,
  }) {
    var list = _categories.values.toList();
    if (includingCodes?.isNotEmpty ?? false) {
      list.removeWhere((wallet) {
        return !includingCodes!.contains(wallet.code);
      });
    }
    if (excludingCodes?.isNotEmpty ?? false) {
      list.removeWhere((wallet) {
        return excludingCodes!.contains(wallet.code);
      });
    }
    if (list.isNotEmpty && page != null && page >= 0 && pageSize != null && pageSize > 0) {
      final offset = page * pageSize;
      list = list.sublist(offset, offset + pageSize);
    }
    return Future.value(DataPage(content: list));
  }

  @override
  Future<void> deleteCategory({
    required String code,
  }) {
    _categories.remove(code);
    return Future.value();
  }

  @override
  Future<void> deleteCategories({required Set<String> codes}) {
    _categories.removeWhere((code, _) {
      return codes.contains(code);
    });
    return Future.value();
  }

  @override
  Future<Budget> saveBudget({
    required Category category,
    required Period period,
    required double amount,
  }) {
    _saveLastUsed(period);

    if (!_categories.containsKey(category.code)) {
      throw ValidationError({
        'category': CategoryError.invalidCategory,
      });
    }
    final budget = _Budget(category, period, amount);
    final errors = budgetValidator?.validate(budget);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    final periodKey = period.toString();
    _values[periodKey] ??= <Budget>{};
    _values[periodKey]!.removeWhere((amount) => amount.category.code == category.code);
    _values[periodKey]!.add(budget);
    return Future.value(budget);
  }

  @override
  Future<List<Budget>> listBudgets({
    required Period period,
    Sort? budgetSort,
    bool showZeroAmount = false,
  }) {
    _saveLastUsed(period);

    final set = _values[period.toString()] ?? {};

    if (showZeroAmount) {
      final includedCategories = set.map((budget) {
        return budget.category;
      });
      final zeroCategories = _categories.values.where((category) {
        return !includedCategories.contains(category);
      });
      set.addAll(zeroCategories.map((category) {
        return _Budget(category, period, 0);
      }));
    }

    return Future.value(set.toList()
      ..sort(
        (value1, value2) {
          if (budgetSort == Sort.asc) {
            return value1.amount.compareTo(value2.amount);
          }
          if (budgetSort == Sort.desc) {
            return value2.amount.compareTo(value1.amount);
          }
          return 0;
        },
      ));
  }

  @override
  Future<void> deleteBudget({
    required Category category,
    required Period period,
  }) {
    _saveLastUsed(period);

    final set = _values[period.toString()] ?? {};
    set.removeWhere((budget) => budget.category == category);
    return Future.value();
  }

  @override
  Future<void> deleteBudgets({
    required Set<String> categoriesCodes,
    required Period period,
  }) {
    _saveLastUsed(period);

    final set = _values[period.toString()] ?? {};
    set.removeWhere((budget) => categoriesCodes.contains(budget.category.code));
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
  Future<bool> copyPreviousPeriodBudgetsInto(Period period) {
    if (_periods.isNotEmpty) {
      final previousPeriodKey = _periods.last;
      final periodKey = period.toString();
      _values[periodKey] = <Budget>{};
      for (var budget in _values[previousPeriodKey]!) {
        _values[periodKey]!.add(budget.copyWith(period: period));
      }
    }
    return Future.value(true);
  }

  @override
  Future<Map<Budget, double>> categoriesTransactionsTotal({
    required Period period,
    bool expensesTransactions = true,
    bool showZeroTotal = false,
  }) async {
    final transactionTypes = TransactionType.values.where((type) {
      if (expensesTransactions) {
        return !type.isIncome;
      }
      return type.isIncome;
    }).toSet();
    final transactions = await DI().get<TransactionService>().listTransactions(
          transactionTypes: transactionTypes,
          period: period,
          dateTimeSort: Sort.asc,
        );
    final map = <Budget, double>{};
    final budgets = _values[period.toString()] ?? {};
    for (var transaction in transactions) {
      final budget = budgets.where((amount) => amount.category == transaction.category).toList();
      if (budget.length == 1) {
        map[budget.first] = (map[budget.first] ?? 0) + transaction.signedAmount;
      }
    }
    if (showZeroTotal) {
      for (var budget in budgets) {
        map[budget] ??= 0;
      }
    }
    return map;
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

class _Budget implements Budget {
  _Budget(this.category, this.period, this.amount);

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
    return other is _Budget && runtimeType == other.runtimeType && category == other.category;
  }

  @override
  int get hashCode {
    return category.code.hashCode;
  }

  @override
  Budget copyWith({required Period period}) {
    return _Budget(category, period, amount);
  }
}
