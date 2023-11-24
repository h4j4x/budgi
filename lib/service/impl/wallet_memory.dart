import '../../error/validation.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../model/wallet.dart';
import '../../model/wallet_error.dart';
import '../../util/string.dart';
import '../transaction.dart';
import '../validator.dart';
import '../wallet.dart';

class WalletMemoryService implements WalletService {
  final TransactionService transactionService;
  final Validator<Wallet, WalletError>? walletValidator;

  final _wallets = <String, Wallet>{};

  WalletMemoryService({
    required this.transactionService,
    this.walletValidator,
  });

  @override
  Future<Wallet> saveWallet({
    String? code,
    required String name,
    required WalletType walletType,
  }) {
    final walletCode = code ?? randomString(6);
    final wallet = _Wallet(walletCode, name, walletType);
    final errors = walletValidator?.validate(wallet);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    _wallets[walletCode] = wallet;
    return Future.value(wallet);
  }

  @override
  Future<List<Wallet>> listWallets() {
    return Future.value(_wallets.values.toList());
  }

  @override
  Future<void> deleteWallet({
    required String code,
  }) {
    _wallets.remove(code);
    return Future.value();
  }

  @override
  Future<Map<Wallet, double>> walletsBalance({required Period period}) async {
    final transactions = await transactionService.listTransactions(
      period: period,
      dateTimeSort: Sort.asc,
    );
    final map = <Wallet, double>{};
    for (var transaction in transactions) {
      map[transaction.wallet] =
          (map[transaction.wallet] ?? 0) + transaction.signedAmount;
    }
    return map;
  }
}

class _Wallet implements Wallet {
  _Wallet(this.code, this.name, this.walletType);

  @override
  String code;

  @override
  String name;

  @override
  WalletType walletType;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _Wallet &&
        runtimeType == other.runtimeType &&
        code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}
