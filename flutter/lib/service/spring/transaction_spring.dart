import 'dart:io';

import '../../model/data_page.dart';
import '../../model/domain/category.dart';
import '../../model/domain/transaction.dart';
import '../../model/domain/wallet.dart';
import '../../model/error/http.dart';
import '../../model/error/transaction.dart';
import '../../model/fields.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../auth.dart';
import '../category.dart';
import '../transaction.dart';
import '../validator.dart';
import '../wallet.dart';
import 'config.dart';
import 'http_client.dart';

class TransactionSpringService implements TransactionService {
  final AuthService authService;
  final CategoryService categoryService;
  final WalletService walletService;
  final Validator<Transaction, TransactionError>? transactionValidator;
  final ApiHttpClient _httpClient;

  TransactionSpringService({
    required this.authService,
    required this.categoryService,
    required this.walletService,
    required this.transactionValidator,
    required SpringConfig config,
  }) : _httpClient = ApiHttpClient(baseUrl: '${config.url}/transaction');

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
  }) async {
    try {
      final dataPage = await _httpClient.jsonGetPage<Map<String, Object>>(
        authService: authService,
        page: page,
        pageSize: pageSize,
        mapper: (map) => map,
      );
      final categoryCodes = dataPage.content
          .map((item) {
            return item[categoryCodeField] as String?;
          })
          .whereType<String>()
          .toSet();
      final categories = (await categoryService.listCategories(includingCodes: categoryCodes)).content;
      final walletCodes = dataPage.content
          .map((item) {
            return item[walletCodeField] as String?;
          })
          .whereType<String>()
          .toSet();
      final wallets = (await walletService.listWallets(includingCodes: walletCodes)).content;
      return DataPage<Transaction>(
        content: dataPage.content
            .map((map) {
              return _SpringTransaction.from(map, categories, wallets);
            })
            .whereType<_SpringTransaction>()
            .toList(),
        pageNumber: dataPage.pageNumber,
        pageSize: dataPage.pageSize,
        totalElements: dataPage.totalElements,
        totalPages: dataPage.totalPages,
      );
    } on SocketException catch (_) {
      throw NoServerError();
    }
  }

  @override
  Future<Transaction> saveTransaction(
      {String? code,
      required TransactionType transactionType,
      required TransactionStatus transactionStatus,
      required Category category,
      required Wallet wallet,
      required double amount,
      DateTime? dateTime,
      String? description,
      int? deferredMonths}) {
    // TODO: implement saveTransaction
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTransaction({required String code}) {
    // TODO: implement deleteTransaction
    throw UnimplementedError();
  }

  @override
  Future<void> saveWalletTransfer(
      {required Category category,
      required Wallet sourceWallet,
      required Wallet targetWallet,
      required double amount,
      DateTime? dateTime,
      String? sourceDescription,
      String? targetDescription}) {
    // TODO: implement saveWalletTransfer
    throw UnimplementedError();
  }
}

class _SpringTransaction extends Transaction {
  @override
  String code;

  @override
  DateTime dateTime;

  @override
  TransactionType transactionType;

  @override
  TransactionStatus transactionStatus;

  @override
  final Wallet wallet;

  @override
  final Category category;

  @override
  double amount;

  @override
  String description;

  _SpringTransaction({
    required this.code,
    required this.category,
    required this.wallet,
    required this.transactionType,
    required this.transactionStatus,
    required this.amount,
    required this.description,
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.now();

  Map<String, Object> toMap() {
    return <String, Object>{
      codeField: code,
      categoryCodeField: category.code,
      walletCodeField: wallet.code,
      transactionTypeField: transactionType.name,
      transactionStatusField: transactionStatus.name,
      amountField: amount,
      descriptionField: description,
      dateTimeField: dateTime.toString(),
    };
  }

  static _SpringTransaction? from(dynamic raw, List<Category> categories, List<Wallet> wallets) {
    if (raw is Map<String, dynamic>) {
      final code = raw[codeField] as String?;
      final categoryCode = raw[categoryCodeField] as String?;
      final category = categories.where((c) => c.code == categoryCode).firstOrNull;
      final walletCode = raw[walletCodeField] as String?;
      final wallet = wallets.where((w) => w.code == walletCode).firstOrNull;
      final transactionType = TransactionType.tryParse(raw[transactionTypeField]);
      final transactionStatus = TransactionStatus.tryParse(raw[transactionStatusField]);
      final amount = raw[amountField] as double?;
      final description = raw[descriptionField] as String?;
      final dateTimeStr = raw[dateTimeField] as String?;
      final dateTime = DateTime.tryParse(dateTimeStr ?? '');
      if (code != null &&
          category != null &&
          wallet != null &&
          transactionType != null &&
          transactionStatus != null &&
          amount != null &&
          description != null &&
          dateTime != null) {
        return _SpringTransaction(
          code: code,
          category: category,
          wallet: wallet,
          transactionType: transactionType,
          transactionStatus: transactionStatus,
          amount: amount,
          description: description,
          dateTime: dateTime,
        );
      }
    }
    return null;
  }
}
