abstract class BudgetCategory {
  String get code;

  set code(String value);

  String get name;

  set name(String value);
}

abstract class BudgetCategoryAmount {
  BudgetCategory get budgetCategory;

  set budgetCategory(BudgetCategory value);

  DateTime get fromDate;

  set fromDate(DateTime value);

  DateTime get toDate;

  set toDate(DateTime value);

  double get amount;

  set amount(double value);
}
