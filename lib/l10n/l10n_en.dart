import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get addAction => 'Add';

  @override
  String get appTitle => 'Budg1';

  @override
  String get budgetAmount => 'Budget amount';

  @override
  String get budgetAmountCategoryHint => 'Select budget category';

  @override
  String get budgetAmountHint => 'Enter budget amount...';

  @override
  String get budgetsCategories => 'Budgets categories';

  @override
  String get budgetCategory => 'Budget category';

  @override
  String get budgetsCategoriesAmounts => 'Budgets categories amounts';

  @override
  String get budgetsCategoryAmount => 'Budget category amount';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameHint => 'Enter category name...';

  @override
  String get createAction => 'Create';

  @override
  String dateMonthYear(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMM(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get editAction => 'Edit';

  @override
  String get fromDate => 'From date';

  @override
  String get home => 'Home';

  @override
  String get invalidBudgetAmount => 'Invalid budget amount. Enter a non negative number for amount.';

  @override
  String get invalidBudgetCategory => 'Invalid category.';

  @override
  String get invalidBudgetCategoryName => 'Invalid budget category name. Enter a non empty name with no more than 255 characters.';

  @override
  String get nothingHere => 'Nothing here :(';

  @override
  String prefixWithDate(String prefix, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$prefix$dateString';
  }

  @override
  String get saveAction => 'Save';

  @override
  String get toDate => 'To date';
}