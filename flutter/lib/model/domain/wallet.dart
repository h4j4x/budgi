import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../l10n/l10n.dart';
import '../period.dart';

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

  static WalletType? tryParse(Object? raw) {
    if (raw is String) {
      final value = raw.trim();
      for (var walletType in values) {
        if (value == walletType.name) {
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Wallet && runtimeType == other.runtimeType && code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}

abstract class WalletBalance {
  Wallet get wallet;

  Period get period;

  double get balance;

  DateTime get updatedAt;
}
