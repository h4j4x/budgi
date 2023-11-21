import '../model/budget_category.dart';
import '../model/period.dart';
import '../model/transaction.dart';
import '../model/wallet.dart';

abstract class TransactionService {
  /// @throws ValidationError
  Future<Transaction> saveTransaction({
    String? code,
    required TransactionType transactionType,
    required Wallet wallet,
    required BudgetCategory budgetCategory,
    required double amount,
    String? description,
  });

  Future<List<Transaction>> listTransactions({
    TransactionType? transactionType,
    Wallet? wallet,
    BudgetCategory? budgetCategory,
    Period? period,
  });

  Future<void> deleteTransaction({
    required String code,
  });
}
