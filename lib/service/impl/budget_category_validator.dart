import '../../model/budget_category.dart';
import '../../model/budget_category_error.dart';
import '../validator.dart';

class BudgetCategoryAmountValidator
    implements Validator<BudgetCategoryAmount, BudgetCategoryError> {
  static const String categoryName = 'category.name';
  static const String amount = 'amount';

  @override
  Map<String, BudgetCategoryError> validate(BudgetCategoryAmount item) {
    final errors = <String, BudgetCategoryError>{};
    if (item.budgetCategory.name.isEmpty) {
      errors[categoryName] = BudgetCategoryError.invalidCategoryName;
    }
    if (item.amount < 0) {
      errors[amount] = BudgetCategoryError.invalidAmount;
    }
    return errors;
  }
}
