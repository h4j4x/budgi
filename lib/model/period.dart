class Period {
  final DateTime from;
  final DateTime to;

  Period({
    required this.from,
    required this.to,
  });

  Period.monthFromDateTime(DateTime dateTime)
      : from = DateTime(dateTime.year, dateTime.month),
        to = DateTime(dateTime.year, dateTime.month + 1).add(const Duration(days: -1));

  static Period get currentMonth {
    return Period.monthFromDateTime(DateTime.now());
  }

  @override
  String toString() {
    final fromStr = '${from.year}${from.month}${from.day}';
    final toStr = '${to.year}${to.month}${to.day}';
    return '$fromStr-$toStr';
  }

  bool contains(DateTime dateTime) {
    return !from.isAfter(dateTime) && !to.isBefore(dateTime);
  }
}
