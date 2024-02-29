import '../../model/data_page.dart';
import '../../model/domain/wallet.dart';
import '../../model/error/validation.dart';
import '../../model/error/wallet.dart';
import '../../model/period.dart';
import '../../util/string.dart';
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
    Set<String>? includingCodes,
    Set<String>? excludingCodes,
    int? page,
    int? pageSize,
  }) {
    var list = _wallets.values.toList();
    if (includingCodes?.isNotEmpty ?? false) {
      list.removeWhere((wallet) {
        return !includingCodes!.contains(wallet.code);
      });
    }
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
  Future<void> deleteWallets({required Set<String> codes}) {
    _wallets.removeWhere((code, _) {
      return codes.contains(code);
    });
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
