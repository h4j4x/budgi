abstract class BudgetCategory {
  String get code;

  set code(String value);

  String get name;

  set name(String value);
}

abstract class BudgetCategoryAmount {
  BudgetCategory get category;

  set category(BudgetCategory value);

  DateTime get fromDate;

  set fromDate(DateTime value);

  DateTime get toDate;

  set toDate(DateTime value);

  double get amount;

  set amount(double value);
}

class BudgetCategoryAmountData {
  final BudgetCategoryAmount? amount;
  final DateTime fromDate;
  final DateTime toDate;

  BudgetCategoryAmountData({
    this.amount,
    required this.fromDate,
    required this.toDate,
  });
}
