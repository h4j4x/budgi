import '../../model/domain/category.dart';
import '../../model/error/category_error.dart';
import '../validator.dart';

class CategoryValidator implements Validator<Category, CategoryError> {
  static const String name = 'name';

  @override
  Map<String, CategoryError> validate(Category item) {
    final errors = <String, CategoryError>{};
    if (item.name.isEmpty) {
      errors[name] = CategoryError.invalidCategoryName;
    }
    return errors;
  }
}

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
