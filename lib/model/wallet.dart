import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

enum WalletType {
  cash,
  creditCard,
  debitCard;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      cash => l10n.walletTypeCash,
      creditCard => l10n.walletTypeCreditCard,
      debitCard => l10n.walletTypeDebitCard,
    };
  }
}

abstract class Wallet {
  String get code;

  WalletType get walletType;

  String get name;
}
