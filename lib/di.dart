import 'package:get_it/get_it.dart';

import 'app/config.dart';
import 'app/info.dart';
import 'service/auth.dart';
import 'service/category.dart';
import 'service/impl/auth_supabase.dart';
import 'service/impl/category_memory.dart';
import 'service/impl/category_validator.dart';
import 'service/impl/transaction_memory.dart';
import 'service/impl/transaction_validator.dart';
import 'service/impl/wallet_memory.dart';
import 'service/impl/wallet_validator.dart';
import 'service/transaction.dart';
import 'service/vendor/supabase.dart';
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

    if (config.hasSupabaseAuth()) {
      final supabaseConfig = SupabaseConfig(url: config.supabaseUrl!, token: config.supabaseToken!);
      await supabaseConfig.initialize();
      _getIt.registerSingleton<AuthService>(AuthSupabaseService(config: supabaseConfig));
    }

    final categoryValidator = CategoryValidator();
    final categoryAmountValidator = CategoryAmountValidator();
    _getIt.registerSingleton<CategoryService>(
      CategoryMemoryService(
        categoryValidator: categoryValidator,
        amountValidator: categoryAmountValidator,
      ),
    );

    final transactionValidator = TransactionValidator();
    _getIt.registerSingleton<TransactionService>(
      TransactionMemoryService(transactionValidator: transactionValidator),
    );

    final walletValidator = WalletValidator();
    _getIt.registerSingleton<WalletService>(
      WalletMemoryService(walletValidator: walletValidator),
    );
  }

  T get<T extends Object>() {
    return _getIt<T>();
  }

  bool has<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
}
