import '../../model/budget_category.dart';
import '../../model/budget_category_error.dart';
import '../validator.dart';

class BudgetCategoryValidator
    implements Validator<BudgetCategory, BudgetCategoryError> {
  static const String name = 'name';

  @override
  Map<String, BudgetCategoryError> validate(BudgetCategory item) {
    final errors = <String, BudgetCategoryError>{};
    if (item.name.isEmpty) {
      errors[name] = BudgetCategoryError.invalidCategoryName;
    }
    return errors;
  }
}

class BudgetCategoryAmountValidator
    implements Validator<BudgetCategoryAmount, BudgetCategoryError> {
  static const String category = 'category';
  static const String amount = 'amount';

  @override
  Map<String, BudgetCategoryError> validate(BudgetCategoryAmount item) {
    final errors = <String, BudgetCategoryError>{};
    if (item.amount < 0) {
      errors[amount] = BudgetCategoryError.invalidAmount;
    }
    return errors;
  }
}
