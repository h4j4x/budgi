import '../model/data_page.dart';
import '../model/domain/wallet.dart';
import '../model/period.dart';

abstract class WalletService {
  /// @throws ValidationError
  Future<Wallet> saveWallet({
    String? code,
    required WalletType walletType,
    required String name,
  });

  Future<DataPage<Wallet>> listWallets({
    Set<String>? includingCodes,
    Set<String>? excludingCodes,
    int? page,
    int? pageSize,
  });

  Future<void> deleteWallet({
    required String code,
  });

  Future<void> deleteWallets({
    required Set<String> codes,
  });

  /// Obtains wallets balance for given period.
  ///
  /// period dates are inclusive.
  Future<Map<Wallet, double>> walletsBalance({
    required Period period,
    bool showZeroBalance = false,
  });
}
