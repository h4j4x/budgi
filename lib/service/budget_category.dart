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
  /// period dates are inclusive.
  Future<List<BudgetCategory>> listCategories({
    bool withAmount = false,
    Period? period,
  });

  Future<void> deleteCategory({
    required String code,
  });

  /// period dates are inclusive.
  ///
  /// Should save given period as last used.
  /// @throws ValidationError
  Future<BudgetCategoryAmount> saveAmount({
    required String categoryCode,
    String? amountCode,
    required Period period,
    required double amount,
  });

  /// period dates are inclusive.
  ///
  /// Should save given period as last used.
  Future<List<BudgetCategoryAmount>> listAmounts({
    required Period period,
    Sort? amountSort,
  });

  /// period dates are inclusive.
  ///
  /// Should save given period as last used.
  Future<void> deleteAmount({
    required String categoryCode,
    required Period period,
  });

  /// returns true if previous used period is different from given one.
  ///
  /// Should NOT save given period as last used.
  Future<bool> periodHasChanged(Period period);

  /// Duplicates previous used period amounts into given one.
  ///
  /// Should save given period as last used.
  Future copyPreviousPeriodAmountsInto(Period period);
}
