import 'package:budgi/service/budget_category.dart';
import 'package:budgi/service/impl/budget_category_memory.dart';
import 'package:get_it/get_it.dart';

class DI {
  static final DI _singleton = DI._();

  factory DI() {
    return _singleton;
  }

  final GetIt _getIt;

  DI._() : _getIt = GetIt.instance;

  void setup() {
    _getIt.registerSingleton<BudgetCategoryService>(
        BudgetCategoryMemoryService());
  }

  BudgetCategoryService getBudgetCategoryService() {
    return _getIt<BudgetCategoryService>();
  }
}
