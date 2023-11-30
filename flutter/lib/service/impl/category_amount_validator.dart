import '../../model/domain/category_amount.dart';
import '../../model/error/category.dart';
import '../validator.dart';

class CategoryAmountValidator
    implements Validator<CategoryAmount, CategoryError> {
  static const String category = 'category';
  static const String amount = 'amount';

  @override
  Map<String, CategoryError> validate(CategoryAmount item) {
    final errors = <String, CategoryError>{};
    if (item.amount < 0) {
      errors[amount] = CategoryError.invalidAmount;
    }
    return errors;
  }
}
