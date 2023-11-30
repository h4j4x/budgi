import 'package:supabase_flutter/supabase_flutter.dart';

import '../../di.dart';
import '../../model/domain/category.dart';
import '../../model/domain/user.dart';
import '../../model/error/category.dart';
import '../../model/error/validation.dart';
import '../../model/fields.dart';
import '../../model/period.dart';
import '../../util/string.dart';
import '../auth.dart';
import '../category.dart';
import '../storage.dart';
import '../validator.dart';
import 'category_amount_supabase.dart';
import 'config.dart';

const categoryTable = 'categories';

class CategorySupabaseService implements CategoryService {
  final SupabaseConfig config;
  final StorageService storageService;
  final Validator<Category, CategoryError>? categoryValidator;

  CategorySupabaseService({
    required this.config,
    required this.storageService,
    this.categoryValidator,
  });

  @override
  Future<Category> saveCategory({
    String? code,
    required String name,
  }) async {
    final user = DI()
        .get<AuthService>()
        .fetchUser(errorIfMissing: CategoryError.invalidUser);

    final categoryCode = code ?? randomString(6);
    final category = SupabaseCategory(code: categoryCode, name: name);
    final errors = categoryValidator?.validate(category);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError<CategoryError>(errors!);
    }

    final categoryExists = await _categoryExistsByCode(categoryCode);
    if (categoryExists) {
      await config.supabase
          .from(categoryTable)
          .update(category.toMap(user))
          .match({codeField: categoryCode});
    } else {
      await config.supabase.from(categoryTable).insert(category.toMap(user));
    }
    return category;
  }

  @override
  Future<List<Category>> listCategories({
    bool withAmount = false,
    Period? period,
    List<String>? excludingCodes,
  }) async {
    final user = DI().get<AuthService>().user();
    if (user == null) {
      return [];
    }

    var query = config.supabase.from(categoryTable).select();
    if (period != null) {
      final ids = await _fetchCategoriesIdsOfAmounts(user.id, period);
      query = query.not(idField, 'in', '(${ids.join(',')})');
    } else {
      query = query.eq(userIdField, user.id);
    }
    if (excludingCodes?.isNotEmpty ?? false) {
      query = query.not(codeField, 'in', '(${excludingCodes!.join(',')})');
    }

    final data = await query;
    if (data is List) {
      return data.map(SupabaseCategory.from).whereType<Category>().toList();
    }
    return [];
  }

  @override
  Future<void> deleteCategory({
    required String code,
  }) async {
    await config.supabase.from(categoryTable).delete().match({codeField: code});
  }

  @override
  Future<Category> fetchCategoryByCode(String code) async {
    final categoryData =
        await config.supabase.from(categoryTable).select().eq(codeField, code);
    final category = SupabaseCategory.from(categoryData);
    if (category != null) {
      return category;
    }
    throw ValidationError({
      'category': CategoryError.invalidCategory,
    });
  }

  @override
  Future<Category?> fetchCategoryById(int id) async {
    final categoryData =
        await config.supabase.from(categoryTable).select().eq(idField, id);
    return SupabaseCategory.from(categoryData);
  }

  Future<List<int>> _fetchCategoriesIdsOfAmounts(
      String userId, Period period) async {
    final data = await config.supabase
        .from(categoryAmountTable)
        .select(categoryIdField)
        .eq(userIdField, userId)
        .eq(fromDateField, period.from.toIso8601String())
        .eq(toDateField, period.to.toIso8601String());
    final list = <int>[];
    if (data is List) {
      for (var item in data) {
        if (item is Map<String, dynamic>) {
          final categoryId = item[categoryIdField] as int?;
          if (categoryId != null) {
            list.add(categoryId);
          }
        }
      }
    }
    return list;
  }

  Future<bool> _categoryExistsByCode(String code) async {
    final count = await config.supabase
        .from(categoryTable)
        .select(
          idField,
          const FetchOptions(
            count: CountOption.exact,
          ),
        )
        .eq(codeField, code);
    return count.count != null && count.count! > 0;
  }
}

class SupabaseCategory implements Category {
  final int id;

  SupabaseCategory({
    this.id = 0,
    required this.code,
    required this.name,
  });

  @override
  String code;

  @override
  String name;

  Map<String, Object> toMap(AppUser user) {
    return <String, Object>{
      userIdField: user.id,
      codeField: code,
      nameField: name,
    };
  }

  static SupabaseCategory? from(dynamic raw) {
    dynamic rawData;
    if (raw is List && raw.isNotEmpty) {
      rawData = raw[0];
    } else {
      rawData = raw;
    }
    if (rawData is Map<String, dynamic>) {
      final id = rawData[idField] as int?;
      final code = rawData[codeField] as String?;
      final name = rawData[nameField] as String?;
      if (id != null && code != null && name != null) {
        return SupabaseCategory(id: id, code: code, name: name);
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is SupabaseCategory &&
        runtimeType == other.runtimeType &&
        code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}
