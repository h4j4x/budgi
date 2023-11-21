enum WalletType {
  cash,
  debitCard,
  creditCard,
}

abstract class Wallet {
  String get code;

  set code(String value);

  WalletType get walletType;

  set walletType(WalletType value);

  String get name;

  set name(String value);
}