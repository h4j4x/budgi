import 'package:budgi/model/period.dart';
import 'package:test/test.dart';

void main() {
  test('currentMonth returns period from current month first to last day', () {
    final period = Period.currentMonth;
    final now = DateTime.now();

    expect(period.from.year, equals(now.year));
    expect(period.to.year, equals(now.year));
    expect(period.from.month, equals(now.month));
    expect(period.to.month, equals(now.month));
    expect(period.from.month, equals(period.to.month));
    expect(period.from.day, equals(1));
    final lastDay =
        DateTime(now.year, now.month + 1).add(const Duration(days: -1));
    expect(period.to.day, equals(lastDay.day));
  });
}
