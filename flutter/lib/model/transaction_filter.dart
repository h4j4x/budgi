import 'domain/category.dart';
import 'domain/transaction.dart';
import 'domain/wallet.dart';
import 'sort.dart';

class TransactionFilter {
  Wallet? wallet;
  Category? category;
  TransactionType? transactionType;
  TransactionStatus? transactionStatus;
  Sort dateTimeSort;

  TransactionFilter({
    required this.wallet,
    required this.category,
    required this.transactionType,
    required this.transactionStatus,
    required this.dateTimeSort,
  });

  factory TransactionFilter.empty() {
    return TransactionFilter(
      wallet: null,
      category: null,
      transactionType: null,
      transactionStatus: null,
      dateTimeSort: Sort.desc,
    );
  }

  TransactionFilter copy() {
    return TransactionFilter(
      wallet: wallet,
      category: category,
      transactionType: transactionType,
      transactionStatus: transactionStatus,
      dateTimeSort: dateTimeSort,
    );
  }
}
