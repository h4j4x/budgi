import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../model/period.dart';

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

  DateTime plusMonths(int months) {
    if (months > 0) {
      return DateTime(year, month + months, day);
    }
    return add(Duration.zero);
  }
}

String formatDateTimePeriod(
  BuildContext context, {
  required Period period,
}) {
  final l10n = L10n.of(context);
  if (period.from.month == period.to.month &&
      period.from.year == period.to.year) {
    return l10n.dateMonthYear(period.from);
  }
  return 'TODO';
}
