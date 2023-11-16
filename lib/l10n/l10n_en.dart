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
  String get budget => 'Budget';

  @override
  String get budgets => 'Budgets';

  @override
  String get createAction => 'Create';

  @override
  String get editAction => 'Edit';

  @override
  String get fromDate => 'From date';

  @override
  String get invalidBudgetCategoryName => 'Invalid budget category name';

  @override
  String prefixWithDate(String prefix, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$prefix$dateString';
  }

  @override
  String get toDate => 'To date';
}
