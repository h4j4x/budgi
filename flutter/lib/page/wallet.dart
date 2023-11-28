import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../model/domain/wallet.dart';
import '../widget/entity/wallet_edit.dart';

class WalletPage extends StatelessWidget {
  static const route = '/wallet';

  final Wallet? value;

  const WalletPage({
    super.key,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final action = value != null ? l10n.editAction : l10n.createAction;
    return Scaffold(
      appBar: AppBar(
        title: Text('$action ${l10n.wallet.toLowerCase()}'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: WalletEdit(
          value: value,
        ),
      ),
    );
  }
}
