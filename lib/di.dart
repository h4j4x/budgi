import 'package:get_it/get_it.dart';

import 'service/budget_category.dart';
import 'service/impl/budget_category_memory.dart';
import 'service/impl/budget_category_validator.dart';

class DI {
  static final DI _singleton = DI._();

  factory DI() {
    return _singleton;
  }

  final GetIt _getIt;

  DI._() : _getIt = GetIt.instance;

  void setup() {
    final budgetCategoryValidator = BudgetCategoryValidator();
    final budgetCategoryAmountValidator = BudgetCategoryAmountValidator();
    _getIt.registerSingleton<BudgetCategoryService>(
      BudgetCategoryMemoryService(
        categoryValidator: budgetCategoryValidator,
        amountValidator: budgetCategoryAmountValidator,
      ),
    );
  }

  BudgetCategoryService budgetCategoryService() {
    return _getIt<BudgetCategoryService>();
  }
}
