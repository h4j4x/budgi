import 'package:flutter/material.dart';

import '../app/icon.dart';
import '../l10n/l10n.dart';

enum Sort {
  asc,
  desc;

  String l10n(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      asc => l10n.sortAsc,
      desc => l10n.sortDesc,
    };
  }

  Widget icon() {
    return switch (this) {
      asc => AppIcon.sortAsc,
      desc => AppIcon.sortDesc,
    };
  }
}
