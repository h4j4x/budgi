class Period {
  final DateTime from;
  final DateTime to;

  Period({
    required this.from,
    required this.to,
  });

  static Period get currentMonth {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month);
    final to = DateTime(now.year, now.month + 1).add(const Duration(days: -1));
    return Period(from: from, to: to);
  }
}
