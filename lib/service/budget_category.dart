import '../model/budget_category.dart';
import '../model/sort.dart';

abstract class BudgetCategoryService {
  /// @throws ValidationError
  Future<BudgetCategory> saveCategory({
    String? categoryCode,
    required String categoryName,
  });

  Future<List<BudgetCategory>> listCategories();

  Future<void> deleteCategory({
    required String code,
  });

  /// @throws ValidationError
  Future<BudgetCategoryAmount> saveAmount({
    required String categoryCode,
    String? amountCode,
    required DateTime fromDate,
    required DateTime toDate,
    required double amount,
  });

  Future<List<BudgetCategoryAmount>> listAmounts({
    required DateTime fromDate,
    required DateTime toDate,
    Sort? amountSort,
  });

  Future<void> deleteAmount({
    required String code,
    required DateTime fromDate,
    required DateTime toDate,
  });
}
