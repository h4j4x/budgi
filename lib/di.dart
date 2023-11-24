import 'package:get_it/get_it.dart';

import 'app/info.dart';
import 'service/category.dart';
import 'service/impl/category_memory.dart';
import 'service/impl/category_validator.dart';
import 'service/impl/transaction_memory.dart';
import 'service/impl/transaction_validator.dart';
import 'service/impl/wallet_memory.dart';
import 'service/impl/wallet_validator.dart';
import 'service/transaction.dart';
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

    final categoryValidator = CategoryValidator();
    final categoryAmountValidator = CategoryAmountValidator();
    _getIt.registerSingleton<CategoryService>(
      CategoryMemoryService(
        categoryValidator: categoryValidator,
        amountValidator: categoryAmountValidator,
      ),
    );

    final transactionValidator = TransactionValidator();
    final transactionService =
        TransactionMemoryService(transactionValidator: transactionValidator);
    _getIt.registerSingleton<TransactionService>(transactionService);

    final walletValidator = WalletValidator();
    _getIt.registerSingleton<WalletService>(
      WalletMemoryService(
        transactionService: transactionService,
        walletValidator: walletValidator,
      ),
    );
  }

  T get<T extends Object>() {
    return _getIt<T>();
  }
}
