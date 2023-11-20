import '../model/budget_category.dart';
import '../model/period.dart';
import '../model/sort.dart';

abstract class BudgetCategoryService {
  /// @throws ValidationError
  Future<BudgetCategory> saveCategory({
    String? code,
    required String name,
  });

  /// If period is not given, withAmount if ignored.
  /// If period is given, response categories are filtered by
  /// withAmounts (true will get categories with registered amounts between the
  /// given interval).
  ///
  /// fromDate and toDate are inclusive.
  Future<List<BudgetCategory>> listCategories({
    bool withAmount = false,
    Period? period,
  });

  Future<void> deleteCategory({
    required String code,
  });

  /// fromDate and toDate are inclusive.
  /// @throws ValidationError
  Future<BudgetCategoryAmount> saveAmount({
    required String categoryCode,
    String? amountCode,
    required Period period,
    required double amount,
  });

  /// fromDate and toDate are inclusive.
  Future<List<BudgetCategoryAmount>> listAmounts({
    required Period period,
    Sort? amountSort,
  });

  /// fromDate and toDate are inclusive.
  Future<void> deleteAmount({
    required String categoryCode,
    required Period period,
  });
}
