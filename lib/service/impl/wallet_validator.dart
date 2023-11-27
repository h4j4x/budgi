import '../../model/wallet.dart';
import '../../model/error/wallet_error.dart';
import '../validator.dart';

class WalletValidator implements Validator<Wallet, WalletError> {
  static const String name = 'name';
  static const String walletType = 'walletType';

  @override
  Map<String, WalletError> validate(Wallet item) {
    final errors = <String, WalletError>{};
    if (item.name.isEmpty) {
      errors[name] = WalletError.invalidWalletName;
    }
    return errors;
  }
}
