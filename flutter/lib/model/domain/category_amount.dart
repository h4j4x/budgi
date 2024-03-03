import '../period.dart';
import 'category.dart';

abstract class Budget {
  Category get category;

  Period get period;

  double get amount;

  Budget copyWith({required Period period});
}

class BudgetData extends Period {
  final Budget? budget;

  BudgetData({
    this.budget,
    required super.from,
    required super.to,
  });

  factory BudgetData.fromPeriod({
    Budget? budget,
    required Period period,
  }) {
    return BudgetData(
      budget: budget,
      from: period.from,
      to: period.to,
    );
  }
}
