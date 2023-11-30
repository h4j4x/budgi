import 'package:flutter/material.dart';

import '../../app/config.dart';
import '../../l10n/l10n.dart';

enum WalletError {
  invalidUser,
  invalidWallet,
  invalidWalletName,
  invalidWalletType;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      invalidUser => l10n.invalidUser,
      invalidWallet => l10n.invalidWallet,
      invalidWalletName => l10n.invalidWalletName(AppConfig.textFieldMaxLength),
      invalidWalletType => l10n.invalidWalletType,
    };
  }
}
