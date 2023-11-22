import '../model/category.dart';
import '../model/period.dart';
import '../model/transaction.dart';
import '../model/wallet.dart';

abstract class TransactionService {
  /// @throws ValidationError
  Future<Transaction> saveTransaction({
    String? code,
    required TransactionType transactionType,
    required Wallet wallet,
    required Category category,
    required double amount,
    String? description,
  });

  Future<List<Transaction>> listTransactions({
    TransactionType? transactionType,
    Wallet? wallet,
    Category? category,
    Period? period,
  });

  Future<void> deleteTransaction({
    required String code,
  });
}
