import 'package:get_it/get_it.dart';

import 'app/config.dart';
import 'app/info.dart';
import 'service/auth.dart';
import 'service/category.dart';
import 'service/budget.dart';
import 'service/impl/category_amount_validator.dart';
import 'service/impl/category_validator.dart';
import 'service/impl/storage.dart';
import 'service/impl/transaction_validator.dart';
import 'service/impl/wallet_validator.dart';
import 'service/memory/category_memory.dart';
import 'service/memory/transaction_memory.dart';
import 'service/memory/wallet_memory.dart';
import 'service/spring/auth_spring.dart';
import 'service/spring/budget_spring.dart';
import 'service/spring/category_spring.dart';
import 'service/spring/config.dart';
import 'service/spring/transaction_spring.dart';
import 'service/spring/wallet_spring.dart';
import 'service/storage.dart';
import 'service/transaction.dart';
import 'service/wallet.dart';

class DI {
  static final DI _singleton = DI._();

  factory DI() {
    return _singleton;
  }

  final GetIt _getIt;

  DI._() : _getIt = GetIt.instance;

  Future setup() async {
    final config = AppConfig.create();
    _getIt.registerSingleton<AppConfig>(config);
    _getIt.registerSingleton<AppInfo>(PackageAppInfo());

    final storageService = SecureStorageService();
    _getIt.registerSingleton<StorageService>(storageService);

    if (config.hasSpringProvider()) {
      await _configSpring(config, storageService);
    } else {
      _configMemory(config);
    }
  }

  T get<T extends Object>() {
    return _getIt<T>();
  }

  bool has<T extends Object>() {
    return _getIt.isRegistered<T>();
  }

  Future<void> _configSpring(
      AppConfig config, StorageService storageService) async {
    final springConfig = SpringConfig(url: config.apiUrl!);
    final authService = AuthSpringService(
      storageService: storageService,
      config: springConfig,
    );
    await authService.initialize();
    _getIt.registerSingleton<AuthService>(authService);

    final categoryService = CategorySpringService(
      authService: authService,
      categoryValidator: CategoryValidator(),
      config: springConfig,
    );
    _getIt.registerSingleton<CategoryService>(categoryService);

    _getIt.registerSingleton<BudgetService>(BudgetSpringService(
      authService: authService,
      budgetValidator: BudgetValidator(),
      config: springConfig,
    ));

    final walletService = WalletSpringService(
      authService: authService,
      config: springConfig,
      walletValidator: WalletValidator(),
    );
    _getIt.registerSingleton<WalletService>(walletService);

    _getIt.registerSingleton<TransactionService>(TransactionSpringService(
      authService: authService,
      categoryService: categoryService,
      walletService: walletService,
      config: springConfig,
      transactionValidator: TransactionValidator(),
    ));
  }

  Future<void> _configMemory(AppConfig config) async {
    final categoryService = CategoryMemoryService(
      categoryValidator: CategoryValidator(),
      budgetValidator: BudgetValidator(),
    );
    _getIt.registerSingleton<CategoryService>(categoryService);
    _getIt.registerSingleton<BudgetService>(categoryService);

    _getIt.registerSingleton<WalletService>(WalletMemoryService(
      walletValidator: WalletValidator(),
    ));

    _getIt.registerSingleton<TransactionService>(TransactionMemoryService(
      transactionValidator: TransactionValidator(),
    ));
  }
}
