import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';

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

  Widget icon() {
    return switch (this) {
      cash => AppIcon.walletCash,
      creditCard => AppIcon.walletCreditCard,
      debitCard => AppIcon.walletDebitCard,
    };
  }

  static WalletType? tryParse(String? value) {
    if (value != null) {
      final theValue = value.trim();
      for (var walletType in values) {
        if (theValue == walletType.name) {
          return walletType;
        }
      }
    }
    return null;
  }
}

abstract class Wallet {
  String get code;

  WalletType get walletType;

  String get name;
}
