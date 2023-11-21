import 'period.dart';

abstract class BudgetCategory {
  String get code;

  set code(String value);

  String get name;

  set name(String value);
}

abstract class BudgetCategoryAmount {
  BudgetCategory get category;

  set category(BudgetCategory value);

  Period get period;

  set period(Period period);

  double get amount;

  set amount(double value);

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
