import '../../model/domain/category_amount.dart';
import '../../model/error/budget.dart';
import '../validator.dart';

class BudgetValidator implements Validator<Budget, BudgetError> {
  static const String category = 'category';
  static const String amount = 'amount';

  @override
  Map<String, BudgetError> validate(Budget item) {
    final errors = <String, BudgetError>{};
    if (item.amount < 0) {
      errors[amount] = BudgetError.invalidAmount;
    }
    return errors;
  }
}
