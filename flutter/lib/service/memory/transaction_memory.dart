import '../../model/data_page.dart';
import '../../model/domain/category.dart';
import '../../model/domain/transaction.dart';
import '../../model/domain/wallet.dart';
import '../../model/error/transaction.dart';
import '../../model/error/validation.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../util/datetime.dart';
import '../../util/string.dart';
import '../transaction.dart';
import '../validator.dart';

class TransactionMemoryService extends TransactionService {
  final Validator<Transaction, TransactionError>? transactionValidator;

  final _transactions = <String, Transaction>{};

  TransactionMemoryService({this.transactionValidator});

  @override
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
  }) {
    final transactionCode = code ?? randomString(6);
    final trnDateTime = dateTime ?? _transactions[transactionCode]?.dateTime ?? DateTime.now();
    final months = deferredMonths != null && deferredMonths > 1 ? deferredMonths : 1;
    Transaction? firstTransaction;
    final theAmount = amount / months;
    for (int i = 0; i < months; i++) {
      final theTransactionCode = i > 0 ? '$transactionCode-${i + 1}' : transactionCode;
      final transaction = _Transaction(
        theTransactionCode,
        category,
        wallet,
        transactionType,
        transactionStatus,
        theAmount,
        description ?? theAmount.toStringAsFixed(2),
        trnDateTime.plusMonths(i),
      );
      final errors = transactionValidator?.validate(transaction);
      if (errors?.isNotEmpty ?? false) {
        throw ValidationError(errors!);
      }
      firstTransaction ??= transaction;
      _transactions[theTransactionCode] = transaction;
    }
    return Future.value(firstTransaction);
  }

  @override
  Future<DataPage<Transaction>> listTransactions({
    Set<TransactionType>? transactionTypes,
    Set<TransactionStatus>? transactionStatuses,
    Category? category,
    Wallet? wallet,
    Period? period,
    Sort? dateTimeSort,
    int? page,
    int? pageSize,
  }) {
    final list = _transactions.values.toList().where((transaction) {
      if (transactionTypes != null && !transactionTypes.contains(transaction.transactionType)) {
        return false;
      }
      if (transactionStatuses != null && !transactionStatuses.contains(transaction.transactionStatus)) {
        return false;
      }
      if (category != null && transaction.category != category) {
        return false;
      }
      if (wallet != null && transaction.wallet != wallet) {
        return false;
      }
      if (period != null && !period.contains(transaction.dateTime)) {
        return false;
      }
      return true;
    }).toList()
      ..sort(
        (value1, value2) {
          if (dateTimeSort == Sort.asc) {
            return value1.dateTime.compareTo(value2.dateTime);
          }
          if (dateTimeSort == Sort.desc) {
            return value2.dateTime.compareTo(value1.dateTime);
          }
          return 0;
        },
      );
    final dataPage = DataPage<Transaction>(content: list, pageNumber: page ?? 0, pageSize: pageSize);
    return Future.value(dataPage);
  }

  @override
  Future<void> deleteTransaction({
    required String code,
  }) {
    _transactions.remove(code);
    return Future.value();
  }
}

class _Transaction extends Transaction {
  @override
  String code;

  @override
  DateTime dateTime;

  @override
  Category category;

  @override
  Wallet wallet;

  @override
  TransactionType transactionType;

  @override
  TransactionStatus transactionStatus;

  @override
  double amount;

  @override
  String description;

  _Transaction(
    this.code,
    this.category,
    this.wallet,
    this.transactionType,
    this.transactionStatus,
    this.amount,
    this.description,
    DateTime? dateTime,
  ) : dateTime = dateTime ?? DateTime.now();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _Transaction && runtimeType == other.runtimeType && code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}
