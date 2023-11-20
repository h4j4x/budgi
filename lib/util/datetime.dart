import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

extension DateTimeExtension on DateTime {
  DateTime atStartOfDay() {
    return copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }
}

String formatDateTimePeriod(
  BuildContext context, {
  required DateTime from,
  required DateTime to,
}) {
  final l10n = L10n.of(context);
  if (from.month == to.month && from.year == to.year) {
    return l10n.dateMonthYear(from);
  }
  return 'TODO';
}
