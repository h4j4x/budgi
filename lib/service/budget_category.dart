import '../model/budget_category.dart';

abstract class BudgetCategoryService {
  Future<BudgetCategoryAmount> saveAmount({
    String? categoryCode,
    required String categoryName,
    required DateTime fromDate,
    required DateTime toDate,
    required double amount,
  });

  Future<List<BudgetCategoryAmount>> listAmounts({
    required DateTime fromDate,
    required DateTime toDate,
  });

  Future<void> removeAmount(String code);
}
