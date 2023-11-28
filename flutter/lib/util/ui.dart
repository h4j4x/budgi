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
}
