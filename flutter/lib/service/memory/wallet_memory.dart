import '../../di.dart';
import '../../model/data_page.dart';
import '../../model/domain/wallet.dart';
import '../../model/error/validation.dart';
import '../../model/error/wallet.dart';
import '../../model/period.dart';
import '../../util/string.dart';
import '../transaction.dart';
import '../validator.dart';
import '../wallet.dart';

class WalletMemoryService implements WalletService {
  final Validator<Wallet, WalletError>? walletValidator;

  final _wallets = <String, Wallet>{};
  final _balances = <String, Set<_WalletBalance>>{};

  WalletMemoryService({
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
  Future<DataPage<Wallet>> listWallets({
    List<String>? excludingCodes,
    int? page,
    int? pageSize,
  }) {
    var list = _wallets.values.toList();
    if (excludingCodes?.isNotEmpty ?? false) {
      list.removeWhere((wallet) {
        return excludingCodes!.contains(wallet.code);
      });
    }
    if (page != null && page >= 0 && pageSize != null && pageSize > 0) {
      final offset = page * pageSize;
      list = list.sublist(offset, offset + pageSize);
    }
    return Future.value(DataPage(content: list));
  }

  @override
  Future<void> deleteWallet({
    required String code,
  }) {
    _wallets.remove(code);
    return Future.value();
  }

  @override
  Future<Map<Wallet, double>> walletsBalance({
    required Period period,
    bool showZeroBalance = false,
  }) {
    final map = <Wallet, double>{};
    if (_balances.containsKey(period.toString())) {
      final balances = _balances[period.toString()]!;
      for (var balance in balances) {
        map[balance.wallet] = balance.balance;
      }
    }
    if (showZeroBalance) {
      for (var wallet in _wallets.values) {
        map[wallet] ??= 0;
      }
    }
    return Future.value(map);
  }

  @override
  Future<Wallet> fetchWalletByCode(String code) {
    return Future.value(_wallets[code]);
  }

  @override
  Future<Wallet?> fetchWalletById(int id) {
    return Future.value();
  }

  @override
  Future<void> updateWalletBalance({
    required String code,
    required Period period,
  }) async {
    if (_wallets.containsKey(code)) {
      final wallet = _wallets[code]!;
      final transactions =
          await DI().get<TransactionService>().listTransactions(
                period: period,
                wallet: wallet,
              );
      final previousPeriod = period.previous;
      double balance = 0;
      if (_balances.containsKey(previousPeriod.toString())) {
        final previousBalance = _balances[period.toString()]!
            .where((element) => element.wallet == wallet)
            .firstOrNull;
        balance = previousBalance?.balance ?? 0;
      }
      for (var transaction in transactions) {
        balance += transaction.signedAmount;
      }
      if (!_balances.containsKey(period.toString())) {
        _balances[period.toString()] = {};
      }
      final walletBalance = _WalletBalance(
        wallet: wallet,
        period: period,
        balance: balance,
        updatedAt: DateTime.now(),
      );
      _balances[period.toString()]!.add(walletBalance);
    }
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

class _WalletBalance implements WalletBalance {
  @override
  final Wallet wallet;

  @override
  final Period period;

  @override
  final double balance;

  @override
  final DateTime updatedAt;

  _WalletBalance({
    required this.wallet,
    required this.period,
    required this.balance,
    required this.updatedAt,
  });
}
