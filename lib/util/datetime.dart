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
