import 'package:budgi/model/domain/category.dart';
import 'package:budgi/model/domain/transaction.dart';
import 'package:budgi/model/domain/wallet.dart';
import 'package:budgi/model/sort.dart';
import 'package:budgi/service/memory/transaction_memory.dart';
import 'package:budgi/service/memory/wallet_memory.dart';
import 'package:test/test.dart';

void main() {
  test(
      '.saveWalletTransfer() mark credit cards pending transactions as completed and create income with rest',
      () async {
    final service = TransactionMemoryService(
      walletService: WalletMemoryService(),
    );
    final category = _TestCategory();
    final creditWallet = _TestWallet(WalletType.creditCard);

    const firstExpenseAmount = 10.0;
    await service.saveTransaction(
      transactionType: TransactionType.expense,
      transactionStatus: TransactionStatus.pending,
      category: category,
      wallet: creditWallet,
      amount: firstExpenseAmount,
    );
    var transactions = await service.listTransactions();
    expect(transactions.length, equals(1));
    expect(
        transactions[0].transactionStatus, equals(TransactionStatus.pending));
    expect(transactions[0].amount, equals(firstExpenseAmount));

    const secondExpenseAmount = 15.0;
    await service.saveTransaction(
      transactionType: TransactionType.expense,
      transactionStatus: TransactionStatus.pending,
      category: category,
      wallet: creditWallet,
      amount: secondExpenseAmount,
    );
    transactions = await service.listTransactions(dateTimeSort: Sort.desc);
    expect(transactions.length, equals(2));
    expect(
        transactions[0].transactionStatus, equals(TransactionStatus.pending));
    expect(transactions[0].amount, equals(secondExpenseAmount));

    const transferAmount = firstExpenseAmount + secondExpenseAmount + 10;
    final cashWallet = _TestWallet(WalletType.cash);
    await service.saveWalletTransfer(
      category: category,
      sourceWallet: cashWallet,
      targetWallet: creditWallet,
      amount: transferAmount,
    );
    transactions = await service.listTransactions(dateTimeSort: Sort.desc);
    expect(transactions.length, equals(4));
    for (var i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      expect(
          transaction.transactionStatus, equals(TransactionStatus.completed));
      if (transaction.code.startsWith('source_')) {
        expect(transaction.wallet.code, equals(cashWallet.code));
        expect(transaction.transactionType,
            equals(TransactionType.expenseTransfer));
        expect(transferAmount, equals(transaction.amount));
      } else if (transaction.code.startsWith('target_')) {
        expect(transaction.wallet.code, equals(creditWallet.code));
        expect(transaction.transactionType,
            equals(TransactionType.incomeTransfer));
        expect(transferAmount, equals(transaction.amount));
      }
    }
  });
}

class _TestCategory extends Category {
  @override
  String get code => 'test';

  @override
  String get name => 'test';
}

class _TestWallet extends Wallet {
  @override
  final String code;

  @override
  final String name;

  @override
  final WalletType walletType;

  _TestWallet(this.walletType)
      : code = walletType.name,
        name = walletType.name;
}
