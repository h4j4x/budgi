import '../model/domain/category.dart';
import '../model/domain/category_amount.dart';
import '../model/period.dart';
import '../model/sort.dart';

abstract class CategoryAmountService {
  /// period dates are inclusive.
  ///
  /// Should save given period as last used.
  /// @throws ValidationError
  Future<CategoryAmount> saveAmount({
    required Category category,
    String? amountCode,
    required Period period,
    required double amount,
  });

  /// period dates are inclusive.
  ///
  /// Should save given period as last used.
  Future<List<CategoryAmount>> listAmounts({
    required Period period,
    Sort? amountSort,
  });

  /// period dates are inclusive.
  ///
  /// Should save given period as last used.
  Future<void> deleteAmount({
    required Category category,
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

  /// Obtains categories transactions total for given period.
  ///
  /// period dates are inclusive.
  Future<Map<CategoryAmount, double>> categoriesTransactionsTotal({
    required Period period,
    bool expensesTransactions = true,
    bool showZeroTotal = false,
  });
}
