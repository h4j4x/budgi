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

    CategoryService categoryService;
    CategoryAmountService categoryAmountService;
    WalletService walletService;
    TransactionService transactionService;

    final categoryValidator = CategoryValidator();
    final categoryAmountValidator = CategoryAmountValidator();
    final walletValidator = WalletValidator();
    final transactionValidator = TransactionValidator();

    if (config.hasSupabaseAuth()) {
      final supabaseConfig = SupabaseConfig(
          url: config.supabaseUrl!, token: config.supabaseToken!);
      await supabaseConfig.initialize();
      _getIt.registerSingleton<AuthService>(
        AuthSupabaseService(config: supabaseConfig),
      );

      categoryService = CategorySupabaseService(
        config: supabaseConfig,
        storageService: storageService,
        categoryValidator: categoryValidator,
      );
      categoryAmountService = CategoryAmountSupabaseService(
        config: supabaseConfig,
        storageService: storageService,
        amountValidator: categoryAmountValidator,
      );
      walletService = WalletSupabaseService(
        config: supabaseConfig,
        walletValidator: walletValidator,
      );
      transactionService = TransactionSupabaseService(
        walletService: walletService,
        config: supabaseConfig,
        transactionValidator: transactionValidator,
      );
    } else {
      categoryService = CategoryMemoryService(
        categoryValidator: categoryValidator,
        amountValidator: categoryAmountValidator,
      );
      categoryAmountService = CategoryMemoryService(
        categoryValidator: categoryValidator,
        amountValidator: categoryAmountValidator,
      );
      walletService = WalletMemoryService(
        walletValidator: walletValidator,
      );
      transactionService = TransactionMemoryService(
        walletService: walletService,
        transactionValidator: transactionValidator,
      );
    }

    _getIt.registerSingleton<CategoryService>(categoryService);
    _getIt.registerSingleton<CategoryAmountService>(categoryAmountService);
    _getIt.registerSingleton<WalletService>(walletService);
    _getIt.registerSingleton<TransactionService>(transactionService);
  }

  T get<T extends Object>() {
    return _getIt<T>();
  }

  bool has<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
}
