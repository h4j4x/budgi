import '../model/data_page.dart';
import '../model/domain/category.dart';

abstract class CategoryService {
  /// @throws ValidationError
  Future<Category> saveCategory({
    String? code,
    required String name,
  });

  Future<DataPage<Category>> listCategories({
    Set<String>? includingCodes,
    Set<String>? excludingCodes,
    int? page,
    int? pageSize,
  });

  Future<void> deleteCategory({
    required String code,
  });

  Future<void> deleteCategories({required Set<String> codes});
}
