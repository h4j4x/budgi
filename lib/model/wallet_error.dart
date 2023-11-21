import 'package:flutter/material.dart';

import '../app/info.dart';
import '../l10n/l10n.dart';

enum WalletError {
  invalidWalletName,
  invalidWalletType;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      invalidWalletName => l10n.invalidWalletName(AppInfo.textFieldMaxLength),
      invalidWalletType => l10n.invalidWalletType,
    };
  }
}
