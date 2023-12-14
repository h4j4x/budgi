import '../model/domain/category.dart';
import '../model/domain/transaction.dart';
import '../model/domain/wallet.dart';
import '../model/period.dart';
import '../model/sort.dart';
import '../util/string.dart';

abstract class TransactionService {
  /// @throws ValidationError
  Future<Transaction> saveTransaction({
    String? code,
    required TransactionType transactionType,
    required Category category,
    required Wallet wallet,
    required double amount,
    DateTime? dateTime,
    String? description,
  });

  /// @throws ValidationError
  Future<void> saveWalletTransfer({
    required Category category,
    required Wallet sourceWallet,
    required Wallet targetWallet,
    required double amount,
    DateTime? dateTime,
    String? sourceDescription,
    String? targetDescription,
  }) async {
    final transactionCode = randomString(6);
    final transactionDateTime = dateTime ?? DateTime.now();
    // source
    final sourceTransactionCode = 'source_$transactionCode';
    await saveTransaction(
      code: sourceTransactionCode,
      transactionType: TransactionType.expense,
      category: category,
      wallet: sourceWallet,
      amount: amount,
      dateTime: transactionDateTime,
      description: sourceDescription ?? targetWallet.name,
    );
    // target
    try {
      await saveTransaction(
        code: 'target_$transactionCode',
        transactionType: TransactionType.income,
        category: category,
        wallet: targetWallet,
        amount: amount,
        dateTime: transactionDateTime,
        description: targetDescription ?? sourceWallet.name,
      );
    } catch (e) {
      await deleteTransaction(code: sourceTransactionCode);
      rethrow;
    }
  }

  Future<List<Transaction>> listTransactions({
    List<TransactionType>? transactionTypes,
    Category? category,
    Wallet? wallet,
    Period? period,
    Sort? dateTimeSort,
  });

  Future<void> deleteTransaction({
    required String code,
  });
}
