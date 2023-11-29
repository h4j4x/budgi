import '../model/domain/category.dart';
import '../model/period.dart';

abstract class CategoryService {
  /// @throws ValidationError
  Future<Category> saveCategory({
    String? code,
    required String name,
  });

  Future<Category> fetchCategoryByCode(String code);

  Future<Category?> fetchCategoryById(int id);

  /// If period is not given, withAmount if ignored.
  /// If period is given, response categories are filtered by
  /// withAmounts (true will get categories with registered amounts between the
  /// given interval).
  ///
  /// period dates are inclusive.
  Future<List<Category>> listCategories({
    bool withAmount = false,
    Period? period,
  });

  Future<void> deleteCategory({
    required String code,
  });
}
