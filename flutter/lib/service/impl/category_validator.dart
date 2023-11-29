import '../../model/domain/category.dart';
import '../../model/error/category.dart';
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
