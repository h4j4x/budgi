import '../../model/budget_category.dart';
import '../../model/budget_category_error.dart';
import '../validator.dart';

class BudgetCategoryAmountValidator
    implements Validator<BudgetCategoryAmount, BudgetCategoryError> {
  static const String categoryName = 'category.name';

  @override
  Map<String, BudgetCategoryError> validate(BudgetCategoryAmount item) {
    final errors = <String, BudgetCategoryError>{};
    if (item.budgetCategory.name.isEmpty) {
      errors[categoryName] = BudgetCategoryError.invalidCategoryName;
    }
    return errors;
  }
}
