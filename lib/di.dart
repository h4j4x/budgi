import 'package:get_it/get_it.dart';

import 'app/info.dart';
import 'service/budget_category.dart';
import 'service/impl/budget_category_memory.dart';
import 'service/impl/budget_category_validator.dart';
import 'service/impl/wallet_memory.dart';
import 'service/impl/wallet_validator.dart';
import 'service/wallet.dart';

class DI {
  static final DI _singleton = DI._();

  factory DI() {
    return _singleton;
  }

  final GetIt _getIt;

  DI._() : _getIt = GetIt.instance;

  void setup() {
    _getIt.registerSingleton<AppInfo>(
      PackageAppInfo(),
    );

    final budgetCategoryValidator = BudgetCategoryValidator();
    final budgetCategoryAmountValidator = BudgetCategoryAmountValidator();
    _getIt.registerSingleton<BudgetCategoryService>(
      BudgetCategoryMemoryService(
        categoryValidator: budgetCategoryValidator,
        amountValidator: budgetCategoryAmountValidator,
      ),
    );

    final walletValidator = WalletValidator();
    _getIt.registerSingleton<WalletService>(
      WalletMemoryService(walletValidator: walletValidator),
    );
  }

  T get<T extends Object>() {
    return _getIt<T>();
  }
}
