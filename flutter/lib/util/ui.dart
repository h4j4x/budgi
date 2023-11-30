import 'package:flutter/material.dart';

import '../app/router.dart';
import '../l10n/l10n.dart';

extension AppContext on BuildContext {
  Future<bool> confirm({
    required String title,
    required String description,
  }) async {
    final value = await showDialog<bool>(
      context: this,
      builder: (context) {
        final l10n = L10n.of(context);
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                pop(true);
              },
              child: Text(l10n.yes),
            ),
            TextButton(
              onPressed: pop,
              child: Text(l10n.no),
            ),
          ],
        );
      },
    );
    return value ?? false;
  }

  void showError(String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(this);
    scaffoldMessenger.removeCurrentSnackBar();
    final theme = Theme.of(this);
    scaffoldMessenger.showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: theme.colorScheme.onError,
        ),
      ),
      backgroundColor: theme.colorScheme.error,
      showCloseIcon: true,
    ));
  }
}
