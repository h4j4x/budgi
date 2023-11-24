import '../../error/validation.dart';
import '../../model/category.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../model/transaction.dart';
import '../../model/transaction_error.dart';
import '../../model/wallet.dart';
import '../../util/string.dart';
import '../transaction.dart';
import '../validator.dart';

class TransactionMemoryService implements TransactionService {
  final Validator<Transaction, TransactionError>? transactionValidator;

  final _transactions = <String, Transaction>{};

  TransactionMemoryService({
    this.transactionValidator,
  });

  @override
  Future<Transaction> saveTransaction({
    String? code,
    required TransactionType transactionType,
    required Category category,
    required Wallet wallet,
    required double amount,
    String? description,
  }) {
    final transactionCode = code ?? randomString(6);
    final dateTime = _transactions[transactionCode]?.dateTime;
    final transaction = _Transaction(
      transactionCode,
      category,
      wallet,
      transactionType,
      amount,
      description ?? 'TODO',
      dateTime,
    );
    final errors = transactionValidator?.validate(transaction);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    _transactions[transactionCode] = transaction;
    return Future.value(transaction);
  }

  @override
  Future<List<Transaction>> listTransactions({
    TransactionType? transactionType,
    Category? category,
    Wallet? wallet,
    Period? period,
    Sort? dateTimeSort,
  }) {
    final list = _transactions.values.toList().where((transaction) {
      if (transactionType != null &&
          transaction.transactionType != transactionType) {
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
    return Future.value(list);
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
  _Transaction(
    this.code,
    this.category,
    this.wallet,
    this.transactionType,
    this.amount,
    this.description,
    DateTime? dateTime,
  ) : dateTime = dateTime ?? DateTime.now();

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
  double amount;

  @override
  String description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _Transaction &&
        runtimeType == other.runtimeType &&
        code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}
