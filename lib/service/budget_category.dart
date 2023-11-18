import '../model/budget_category.dart';
import '../model/sort.dart';

abstract class BudgetCategoryService {
  /// @throws ValidationError
  Future<BudgetCategory> saveCategory({
    String? code,
    required String name,
  });

  /// If fromDate or toDate are not given, withAmount if ignored.
  /// If fromDate and toDate are both given, response categories are filtered by
  /// withAmounts (true will get categories with registered amounts between the
  /// given interval).
  ///
  /// fromDate and toDate are inclusive.
  Future<List<BudgetCategory>> listCategories({
    bool withAmount = false,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<void> deleteCategory({
    required String code,
  });

  /// fromDate and toDate are inclusive.
  /// @throws ValidationError
  Future<BudgetCategoryAmount> saveAmount({
    required String categoryCode,
    String? amountCode,
    required DateTime fromDate,
    required DateTime toDate,
    required double amount,
  });

  /// fromDate and toDate are inclusive.
  Future<List<BudgetCategoryAmount>> listAmounts({
    required DateTime fromDate,
    required DateTime toDate,
    Sort? amountSort,
  });

  /// fromDate and toDate are inclusive.
  Future<void> deleteAmount({
    required String categoryCode,
    required DateTime fromDate,
    required DateTime toDate,
  });
}
