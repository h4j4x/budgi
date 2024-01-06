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
import '../../util/datetime.dart';
import '../../util/function.dart';
import '../../util/string.dart';
import '../auth.dart';
import '../category.dart';
import '../transaction.dart';
import '../validator.dart';
import 'category_supabase.dart';
import 'config.dart';
import 'wallet_supabase.dart';

const transactionTable = 'transactions';

class TransactionSupabaseService extends TransactionService {
  final SupabaseConfig config;
  final Validator<Transaction, TransactionError>? transactionValidator;

  TransactionSupabaseService({
    required super.walletService,
    required this.config,
    this.transactionValidator,
  });

  @override
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

    final transactionCode = code ?? randomString(6);
    final transactionExists = await _transactionExistsByCode(transactionCode);
    final months =
        deferredMonths != null && deferredMonths > 1 ? deferredMonths : 1;
    if (transactionExists && months > 1) {
      throw ValidationError({
        'months': TransactionError.invalidTransactionDeferredMonths,
      });
    }

    final user = DI()
        .get<AuthService>()
        .fetchUser(errorIfMissing: TransactionError.invalidUser);
    final trnDateTime = dateTime ?? DateTime.now();

    Transaction? firstTransaction;
    final theAmount = amount / months;
    for (int i = 0; i < months; i++) {
      final theTransactionCode =
          i > 0 ? '$transactionCode-${i + 1}' : transactionCode;
      final transaction = _Transaction(
        category: category,
        wallet: wallet,
        code: theTransactionCode,
        transactionType: transactionType,
        transactionStatus: transactionStatus,
        amount: theAmount,
        dateTime: trnDateTime.plusMonths(i),
        description: description ?? theAmount.toStringAsFixed(2),
      );
      final errors = transactionValidator?.validate(transaction);
      if (errors?.isNotEmpty ?? false) {
        throw ValidationError(errors!);
      }

      firstTransaction ??= transaction;

      if (transactionExists) {
        await config.supabase
            .from(transactionTable)
            .update(transaction.toMap(user))
            .match({
          codeField: transactionCode,
        });
      } else {
        await config.supabase
            .from(transactionTable)
            .insert(transaction.toMap(user));
      }
    }

    return firstTransaction!;
  }

  @override
  Future<List<Transaction>> listTransactions({
    List<TransactionType>? transactionTypes,
    List<TransactionStatus>? transactionStatuses,
    List<WalletType>? walletTypes,
    Category? category,
    Wallet? wallet,
    Period? period,
    Sort? dateTimeSort,
  }) async {
    final user = DI().get<AuthService>().user();
    if (user == null) {
      return [];
    }

    var query = config.supabase
        .from(transactionTable)
        .select()
        .eq(userIdField, user.id);
    if (transactionTypes?.isNotEmpty ?? false) {
      query = query.inFilter(
          transactionTypeField,
          transactionTypes!.map((transactionType) {
            return transactionType.name;
          }).toList());
    }
    if (transactionStatuses?.isNotEmpty ?? false) {
      query = query.inFilter(
          transactionStatusField,
          transactionStatuses!.map((transactionStatus) {
            return transactionStatus.name;
          }).toList());
    }
    if (walletTypes?.isNotEmpty ?? false) {
      query = query.inFilter(
          walletTypeField,
          walletTypes!.map((walletType) {
            return walletType.name;
          }).toList());
    }
    if (category is SupabaseCategory) {
      query = query.eq(categoryIdField, category.id);
    }
    if (wallet is SupabaseWallet) {
      query = query.eq(walletIdField, wallet.id);
    }
    if (period != null) {
      query = query
          .gte(dateTimeField, period.from.toIso8601String())
          .lte(dateTimeField, period.to.toIso8601String());
    }

    dynamic data;
    if (dateTimeSort != null) {
      data =
          await query.order(dateTimeField, ascending: dateTimeSort == Sort.asc);
    } else {
      data = await query;
    }

    if (data is List) {
      final futureList = data.map((item) {
        return _Transaction.from(
          item,
          categoryFetcher: _fetchCategoryById,
          walletFetcher: _fetchWalletById,
        );
      });
      final list = await Future.wait(futureList);
      return list.whereType<Transaction>().toList();
    }
    return [];
  }

  @override
  Future<void> deleteTransaction({required String code}) async {
    await config.supabase
        .from(transactionTable)
        .delete()
        .match({codeField: code});
  }

  Future<bool> _transactionExistsByCode(String code) async {
    final count = await config.supabase
        .from(transactionTable)
        .select(idField)
        .eq(codeField, code)
        .count(CountOption.exact);
    return count.count > 0;
  }

  Future<SupabaseCategory?> _fetchCategoryById(int id) async {
    final category = await DI().get<CategoryService>().fetchCategoryById(id);
    if (category is SupabaseCategory) {
      return category;
    }
    return null;
  }

  Future<SupabaseWallet?> _fetchWalletById(int id) async {
    final wallet = await walletService.fetchWalletById(id);
    if (wallet is SupabaseWallet) {
      return wallet;
    }
    return null;
  }
}

class _Transaction extends Transaction {
  final int id;
  final SupabaseCategory _category;
  final SupabaseWallet _wallet;

  @override
  String code;

  @override
  TransactionType transactionType;

  @override
  TransactionStatus transactionStatus;

  @override
  double amount;

  @override
  DateTime dateTime;

  @override
  String description;

  _Transaction({
    this.id = 0,
    required SupabaseCategory category,
    required SupabaseWallet wallet,
    required this.code,
    required this.transactionType,
    required this.transactionStatus,
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

  Map<String, Object> toMap(AppUser user) {
    return <String, Object>{
      userIdField: user.id,
      categoryIdField: _category.id,
      walletIdField: _wallet.id,
      codeField: code,
      transactionTypeField: transactionType.name,
      transactionStatusField: transactionStatus.name,
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
      final transactionType =
          TransactionType.tryParse(raw[transactionTypeField] as String?);
      final transactionStatus =
          TransactionStatus.tryParse(raw[transactionStatusField] as String?);
      final amount = raw[amountField] as num?;
      final dateTime = DateTime.tryParse((raw[dateTimeField] as String?) ?? '');
      final description = raw[descriptionField] as String?;
      if (id != null &&
          categoryId != null &&
          walletId != null &&
          code != null &&
          transactionType != null &&
          transactionStatus != null &&
          amount != null &&
          dateTime != null &&
          description != null) {
        final category = await categoryFetcher(categoryId);
        final wallet = await walletFetcher(walletId);
        if (category != null && wallet != null) {
          return _Transaction(
            id: id,
            category: category,
            wallet: wallet,
            code: code,
            transactionType: transactionType,
            transactionStatus: transactionStatus,
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
    return other is _Transaction &&
        runtimeType == other.runtimeType &&
        code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}
