import '../model/domain/category.dart';
import '../model/period.dart';
import '../model/sort.dart';
import '../model/domain/transaction.dart';
import '../model/domain/wallet.dart';

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