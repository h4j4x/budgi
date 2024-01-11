import 'package:get_it/get_it.dart';

import 'app/config.dart';
import 'app/info.dart';
import 'service/auth.dart';
import 'service/category.dart';
import 'service/category_amount.dart';
import 'service/impl/category_amount_validator.dart';
import 'service/impl/category_validator.dart';
import 'service/impl/storage.dart';
import 'service/impl/transaction_validator.dart';
import 'service/impl/wallet_validator.dart';
import 'service/memory/category_memory.dart';
import 'service/memory/transaction_memory.dart';
import 'service/memory/wallet_memory.dart';
import 'service/spring/auth_spring.dart';
import 'service/spring/config.dart';
import 'service/spring/wallet_spring.dart';
import 'service/storage.dart';
import 'service/supabase/auth_supabase.dart';
import 'service/supabase/category_amount_supabase.dart';
import 'service/supabase/category_supabase.dart';
import 'service/supabase/config.dart';
import 'service/supabase/transaction_supabase.dart';
import 'service/supabase/wallet_supabase.dart';
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

    if (config.hasSupabaseProvider()) {
      await _configSupabase(config, storageService);
    } else if (config.hasSpringProvider()) {
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

  Future<void> _configSupabase(AppConfig config, StorageService storageService) async {
    final supabaseConfig = SupabaseConfig(
      url: config.apiUrl!,
      token: config.apiToken!,
    );
    await supabaseConfig.initialize();

    _getIt.registerSingleton<AuthService>(
      AuthSupabaseService(config: supabaseConfig),
    );

    _getIt.registerSingleton<CategoryService>(CategorySupabaseService(
      config: supabaseConfig,
      storageService: storageService,
      categoryValidator: CategoryValidator(),
    ));

    _getIt.registerSingleton<CategoryAmountService>(CategoryAmountSupabaseService(
      config: supabaseConfig,
      storageService: storageService,
      amountValidator: CategoryAmountValidator(),
    ));

    final walletService = WalletSupabaseService(
      config: supabaseConfig,
      walletValidator: WalletValidator(),
    );
    _getIt.registerSingleton<WalletService>(walletService);

    _getIt.registerSingleton<TransactionService>(TransactionSupabaseService(
      walletService: walletService,
      config: supabaseConfig,
      transactionValidator: TransactionValidator(),
    ));
  }

  Future<void> _configSpring(AppConfig config, StorageService storageService) async {
    final springConfig = SpringConfig(url: config.apiUrl!);
    final authService = AuthSpringService(
      storageService: storageService,
      config: springConfig,
    );
    await authService.initialize();
    _getIt.registerSingleton<AuthService>(authService);

    // TODO: implement service
    final categoryService = CategoryMemoryService(
      categoryValidator: CategoryValidator(),
      amountValidator: CategoryAmountValidator(),
    );
    _getIt.registerSingleton<CategoryService>(categoryService);
    _getIt.registerSingleton<CategoryAmountService>(categoryService);

    final walletService = WalletSpringService(
      authService: authService,
      config: springConfig,
      walletValidator: WalletValidator(),
    );
    _getIt.registerSingleton<WalletService>(walletService);

    // TODO: implement service
    _getIt.registerSingleton<TransactionService>(TransactionMemoryService(
      walletService: walletService,
      transactionValidator: TransactionValidator(),
    ));
  }

  Future<void> _configMemory(AppConfig config) async {
    final categoryService = CategoryMemoryService(
      categoryValidator: CategoryValidator(),
      amountValidator: CategoryAmountValidator(),
    );
    _getIt.registerSingleton<CategoryService>(categoryService);
    _getIt.registerSingleton<CategoryAmountService>(categoryService);

    final walletService = WalletMemoryService(
      walletValidator: WalletValidator(),
    );
    _getIt.registerSingleton<WalletService>(walletService);

    _getIt.registerSingleton<TransactionService>(TransactionMemoryService(
      walletService: walletService,
      transactionValidator: TransactionValidator(),
    ));
  }
}
