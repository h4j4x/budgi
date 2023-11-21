import '../model/period.dart';
import '../model/wallet.dart';

abstract class WalletService {
  /// @throws ValidationError
  Future<Wallet> saveWallet({
    String? code,
    required WalletType walletType,
    required String name,
  });

  Future<List<Wallet>> listWallets();

  Future<void> deleteWallet({
    required String code,
  });

  /// period dates are inclusive.
  Future<Map<Wallet, double>> walletsBalance({
    required Period period,
  });
}
