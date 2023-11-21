import 'period.dart';

abstract class BudgetCategory {
  String get code;

  String get name;
}

abstract class BudgetCategoryAmount {
  BudgetCategory get category;

  Period get period;

  double get amount;

  BudgetCategoryAmount copyWith({required Period period});
}

class BudgetCategoryAmountData extends Period {
  final BudgetCategoryAmount? amount;

  BudgetCategoryAmountData({
    this.amount,
    required super.from,
    required super.to,
  });

  factory BudgetCategoryAmountData.fromPeriod({
    BudgetCategoryAmount? amount,
    required Period period,
  }) {
    return BudgetCategoryAmountData(
      amount: amount,
      from: period.from,
      to: period.to,
    );
  }
}
