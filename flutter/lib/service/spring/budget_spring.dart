import 'dart:io';

import '../../model/domain/category.dart';
import '../../model/domain/category_amount.dart';
import '../../model/error/budget.dart';
import '../../model/error/category.dart';
import '../../model/error/http.dart';
import '../../model/error/validation.dart';
import '../../model/fields.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../util/datetime.dart';
import '../auth.dart';
import '../budget.dart';
import '../category.dart';
import '../validator.dart';
import 'config.dart';
import 'http_client.dart';

class BudgetSpringService implements BudgetService {
  final AuthService authService;
  final CategoryService categoryService;
  final Validator<Budget, BudgetError> budgetValidator;
  final ApiHttpClient _httpClient;

  BudgetSpringService({
    required this.authService,
    required this.categoryService,
    required this.budgetValidator,
    required SpringConfig config,
  }) : _httpClient = ApiHttpClient(baseUrl: '${config.url}/category-budget');

  @override
  Future<List<Budget>> listBudgets({
    required Period period,
    Sort? budgetSort,
    bool showZeroAmount = false,
  }) async {
    try {
      final page = await _httpClient.jsonGetPage<dynamic>(
        authService: authService,
        page: 0,
        pageSize: 9999,
        data: {
          fromDateField: period.from.toDateString(),
          toDateField: period.to.toDateString(),
        },
        mapper: (item) => item,
      );
      final categoryCodes = page
          .map((item) {
            return item[categoryCodeField] as String?;
          })
          .whereType<String>()
          .toSet();
      final categories = (await categoryService.listCategories(includingCodes: categoryCodes)).content;
      return page.map((map) => _SpringBudget.from(map, categories)).whereType<Budget>().toList();
    } on SocketException catch (_) {
      throw NoServerError();
    }
  }

  @override
  Future<Budget> saveBudget({
    required Category category,
    required Period period,
    required double amount,
  }) async {
    final budget = _SpringBudget(category: category, period: period, amount: amount);
    final errors = budgetValidator.validate(budget);
    if (errors.isNotEmpty) {
      throw ValidationError(errors);
    }
    try {
      final response = await _httpClient.jsonPost<Map<String, dynamic>>(
        authService: authService,
        data: budget.toMap(),
      );
      return _SpringBudget.from(response, [category])!;
    } on SocketException catch (_) {
      throw NoServerError();
    }
  }

  @override
  Future<void> deleteBudget({
    required Category category,
    required Period period,
  }) async {
    try {
      await _httpClient.delete(authService: authService, path: '/${category.code}');
    } on SocketException catch (_) {
      throw NoServerError();
    } catch (e) {
      throw ValidationError({
        'category': CategoryError.invalidCategory,
      });
    }
  }

  @override
  Future<Map<Budget, double>> categoriesTransactionsTotal({
    required Period period,
    bool expensesTransactions = true,
    bool showZeroTotal = false,
  }) {
    // TODO: implement categoriesTransactionsTotal
    throw UnimplementedError();
  }

  @override
  Future<bool> copyPreviousPeriodBudgetsInto(Period period) async {
    try {
      await _httpClient.jsonPost(authService: authService, path: '/copy-previous-period', data: {
        fromDateField: period.from.toDateString(),
        toDateField: period.to.toDateString(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> periodHasChanged(Period period) async {
    try {
      final count = await _httpClient.jsonGet<int>(authService: authService, path: '/count', data: {
        fromDateField: period.from.toDateString(),
        toDateField: period.to.toDateString(),
      });
      return count < 1;
    } catch (_) {
      return false;
    }
  }
}

class _SpringBudget implements Budget {
  @override
  Category category;

  @override
  Period period;

  @override
  double amount;

  _SpringBudget({
    required this.category,
    required this.period,
    required this.amount,
  });

  Map<String, Object> toMap() {
    return <String, Object>{
      categoryCodeField: category.code,
      fromDateField: period.from.toDateString(),
      toDateField: period.to.toDateString(),
      amountField: amount,
    };
  }

  static _SpringBudget? from(dynamic raw, List<Category> categories) {
    if (raw is Map<String, dynamic>) {
      final categoryCode = raw[categoryCodeField] as String?;
      final category = categories.where((c) => c.code == categoryCode).firstOrNull;
      final fromDateStr = raw[fromDateField] as String?;
      final fromDate = DateTime.tryParse(fromDateStr ?? '');
      final toDateStr = raw[toDateField] as String?;
      final toDate = DateTime.tryParse(toDateStr ?? '');
      final amount = raw[amountField] as double?;
      if (category != null && fromDate != null && toDate != null && amount != null) {
        return _SpringBudget(category: category, period: Period(from: fromDate, to: toDate), amount: amount);
      }
    }
    return null;
  }

  @override
  Budget copyWith({required Period period}) {
    return _SpringBudget(category: category, period: period, amount: amount);
  }
}
