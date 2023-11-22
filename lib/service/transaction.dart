import '../model/category.dart';
import '../model/period.dart';
import '../model/transaction.dart';
import '../model/wallet.dart';

abstract class TransactionService {
  /// @throws ValidationError
  Future<Transaction> saveTransaction({
    String? code,
    required TransactionType transactionType,
    required Category category,
    required Wallet wallet,
    required double amount,
    String? description,
  });

  Future<List<Transaction>> listTransactions({
    TransactionType? transactionType,
    Category? category,
    Wallet? wallet,
    Period? period,
  });

  Future<void> deleteTransaction({
    required String code,
  });
}
