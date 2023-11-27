import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../model/domain/transaction.dart';
import '../widget/entity/transaction_edit.dart';

class TransactionPage extends StatelessWidget {
  static const route = '/transaction';

  final Transaction? value;

  const TransactionPage({
    super.key,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final action = value != null ? l10n.editAction : l10n.createAction;
    return Scaffold(
      appBar: AppBar(
        title: Text('$action ${l10n.transaction.toLowerCase()}'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: TransactionEdit(
          value: value,
        ),
      ),
    );
  }
}
