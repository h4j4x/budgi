import 'package:meta/meta.dart';

import '../model/domain/category.dart';
import '../model/domain/transaction.dart';
import '../model/domain/wallet.dart';
import '../model/period.dart';
import '../model/sort.dart';
import '../util/string.dart';
import 'wallet.dart';

abstract class TransactionService {
  final WalletService walletService;

  TransactionService({required this.walletService});

  /// @throws ValidationError
  Future<Transaction> saveTransaction({
    String? code,
    required TransactionType transactionType,
    required TransactionStatus transactionStatus,
    required Category category,
    required Wallet wallet,
    required double amount,
    DateTime? dateTime,
    String? description,
    int? deferredMonths,
  }) async {
    final transaction = await doSaveTransaction(
      code: code,
      transactionType: transactionType,
      transactionStatus: transactionStatus,
      category: category,
      wallet: wallet,
      amount: amount,
      dateTime: dateTime,
      description: description,
      deferredMonths: deferredMonths,
    );
    final period = Period.monthFromDateTime(transaction.dateTime);
    await walletService.updateWalletBalance(
      code: transaction.wallet.code,
      period: period,
    );
    return transaction;
  }

  @protected
  Future<Transaction> doSaveTransaction({
    String? code,
    required TransactionType transactionType,
    required TransactionStatus transactionStatus,
    required Category category,
    required Wallet wallet,
    required double amount,
    DateTime? dateTime,
    String? description,
    int? deferredMonths,
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
      transactionType: TransactionType.expenseTransfer,
      transactionStatus: TransactionStatus.completed,
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
        transactionType: TransactionType.incomeTransfer,
        transactionStatus: TransactionStatus.completed,
        category: category,
        wallet: targetWallet,
        amount: amount,
        dateTime: transactionDateTime,
        description: targetDescription ?? sourceWallet.name,
      );
      if (targetWallet.walletType == WalletType.creditCard) {
        await _completePendingTransactions(targetWallet, maxAmount: amount);
      }
    } catch (e) {
      await deleteTransaction(code: sourceTransactionCode);
      rethrow;
    }
  }

  Future<void> _completePendingTransactions(Wallet wallet,
      {required double maxAmount}) async {
    final transactions = await listTransactions(
      transactionStatuses: [TransactionStatus.pending],
      dateTimeSort: Sort.asc,
    );
    double restAmount = maxAmount;
    for (var transaction in transactions) {
      if (restAmount == 0 || restAmount < transaction.amount) {
        break;
      }
      restAmount -= transaction.amount;
      await saveTransaction(
        code: transaction.code,
        transactionType: transaction.transactionType,
        transactionStatus: TransactionStatus.completed,
        category: transaction.category,
        wallet: transaction.wallet,
        amount: transaction.amount,
        dateTime: transaction.dateTime,
        description: transaction.description,
      );
    }
  }

  Future<List<Transaction>> listTransactions({
    List<TransactionType>? transactionTypes,
    List<TransactionStatus>? transactionStatuses,
    Category? category,
    Wallet? wallet,
    Period? period,
    Sort? dateTimeSort,
  });

  Future<void> deleteTransaction({
    required String code,
  });
}
