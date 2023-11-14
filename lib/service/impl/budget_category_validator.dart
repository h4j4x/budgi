import '../../model/budget_category.dart';
import '../validator.dart';

class BudgetCategoryAmountValidator implements Validator<BudgetCategoryAmount> {
  static const String categoryName = 'category.name';

  @override
  Map<String, String> validate(BudgetCategoryAmount item) {
    final errors = <String, String>{};
    if (item.budgetCategory.name.isEmpty) {
      errors[categoryName] = 'Invalid category name.'; // TODO
    }
    return errors;
  }
}
