import 'package:supabase_flutter/supabase_flutter.dart';

import '../../di.dart';
import '../../model/domain/category.dart';
import '../../model/domain/transaction.dart';
import '../../model/domain/user.dart';
import '../../model/domain/wallet.dart';
import '../../model/error/transaction.dart';
import '../../model/error/validation.dart';
import '../../model/fields.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../util/function.dart';
import '../../util/string.dart';
import '../auth.dart';
import '../transaction.dart';
import '../validator.dart';
import 'category_supabase.dart';
import 'supabase.dart';
import 'wallet_supabase.dart';

const transactionTable = 'transactions';

class TransactionSupabaseService implements TransactionService {
  final SupabaseConfig config;
  final Validator<Transaction, TransactionError>? transactionValidator;

  TransactionSupabaseService({
    required this.config,
    this.transactionValidator,
  });

  @override
  Future<Transaction> saveTransaction({
    String? code,
    required TransactionType transactionType,
    required Category category,
    required Wallet wallet,
    required double amount,
    DateTime? dateTime,
    String? description,
  }) async {
    if (category is! SupabaseCategory) {
      throw ValidationError({
        'category': TransactionError.invalidCategory,
      });
    }
    if (wallet is! SupabaseWallet) {
      throw ValidationError({
        'wallet': TransactionError.invalidWallet,
      });
    }

    final user = DI().get<AuthService>().fetchUser(errorIfMissing: TransactionError.invalidUser);
    final transactionCode = code ?? randomString(6);

    final transaction = _Transaction(
      category: category,
      wallet: wallet,
      code: transactionCode,
      transactionType: transactionType,
      amount: amount,
      dateTime: dateTime ?? DateTime.now(),
      description: description ?? 'TODO',
    );
    final errors = transactionValidator?.validate(transaction);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    final transactionExists = await _transactionExistsByCode(transactionCode);
    if (transactionExists) {
      await config.supabase.from(transactionTable).update(transaction.toMap(user)).match({
        codeField: transactionCode,
      });
    } else {
      await config.supabase.from(transactionTable).insert(transaction.toMap(user));
    }
    return transaction;
  }

  @override
  Future<List<Transaction>> listTransactions(
      {List<TransactionType>? transactionTypes,
      Category? category,
      Wallet? wallet,
      Period? period,
      Sort? dateTimeSort}) {
    // TODO: implement listTransactions
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTransaction({required String code}) {
    // TODO: implement deleteTransaction
    throw UnimplementedError();
  }

  Future<bool> _transactionExistsByCode(String code) async {
    final count = await config.supabase
        .from(transactionTable)
        .select(
          idField,
          const FetchOptions(
            count: CountOption.exact,
          ),
        )
        .eq(codeField, code);
    return count.count != null && count.count! > 0;
  }
}

class _Transaction extends Transaction {
  final int id;
  final SupabaseCategory _category;
  final SupabaseWallet _wallet;

  _Transaction({
    this.id = 0,
    required SupabaseCategory category,
    required SupabaseWallet wallet,
    required this.code,
    required this.transactionType,
    required this.amount,
    required this.dateTime,
    required this.description,
  })  : _category = category,
        _wallet = wallet;

  @override
  Category get category {
    return _category;
  }

  @override
  Wallet get wallet {
    return _wallet;
  }

  @override
  String code;

  @override
  TransactionType transactionType;

  @override
  double amount;

  @override
  DateTime dateTime;

  @override
  String description;

  Map<String, Object> toMap(AppUser user) {
    return <String, Object>{
      userIdField: user.id,
      categoryIdField: _category.id,
      walletIdField: _wallet.id,
      codeField: code,
      transactionTypeField: transactionType,
      amountField: amount,
      dateTimeField: dateTime.toIso8601String(),
      descriptionField: description,
    };
  }

  static Future<_Transaction?> from(
    dynamic raw, {
    required TypedFutureFetcher<SupabaseCategory, int> categoryFetcher,
    required TypedFutureFetcher<SupabaseWallet, int> walletFetcher,
  }) async {
    if (raw is Map<String, dynamic>) {
      final id = raw[idField] as int?;
      final categoryId = raw[categoryIdField] as int?;
      final walletId = raw[walletIdField] as int?;
      final code = raw[codeField] as String?;
      final transactionType = TransactionType.tryParse(raw[transactionTypeField] as String?);
      final amount = raw[amountField] as num?;
      final dateTime = DateTime.tryParse((raw[dateTimeField] as String?) ?? '');
      final description = raw[descriptionField] as String?;
      if (id != null &&
          categoryId != null &&
          walletId != null &&
          code != null &&
          transactionType != null &&
          amount != null &&
          dateTime != null &&
          description != null) {
        final category = await categoryFetcher(categoryId);
        final wallet = await walletFetcher(walletId);
        if (category != null && wallet != null) {
          return _Transaction(
            category: category,
            wallet: wallet,
            code: code,
            transactionType: transactionType,
            amount: amount.toDouble(),
            dateTime: dateTime,
            description: description,
          );
        }
      }
    }
    return null;
  }

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
