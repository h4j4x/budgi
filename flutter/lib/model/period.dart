class Period {
  final DateTime from;
  final DateTime to;

  Period({
    required this.from,
    required this.to,
  });

  Period.monthFromDateTime(DateTime dateTime)
      : from = DateTime(dateTime.year, dateTime.month),
        to = DateTime(dateTime.year, dateTime.month + 1)
            .add(const Duration(days: -1))
            .copyWith(hour: 23, minute: 59, second: 59);

  static Period get currentMonth {
    return Period.monthFromDateTime(DateTime.now());
  }

  static Period? tryParse(String? value) {
    if (value != null) {
      final parts = value.split('-');
      if (parts.length == 2) {
        final from = DateTime.tryParse(parts[0]);
        final to = DateTime.tryParse(parts[1]);
        if (from != null && to != null) {
          return Period(from: from, to: to);
        }
      }
    }
    return null;
  }

  @override
  String toString() {
    return '${from.toIso8601String()}-${to.toIso8601String()}';
  }

  bool contains(DateTime dateTime) {
    return !from.isAfter(dateTime) && !to.isBefore(dateTime);
  }
}
