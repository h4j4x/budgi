import 'dart:io';

import '../../model/data_page.dart';
import '../../model/domain/category.dart';
import '../../model/error/category.dart';
import '../../model/error/http.dart';
import '../../model/error/validation.dart';
import '../../model/fields.dart';
import '../auth.dart';
import '../category.dart';
import '../validator.dart';
import 'config.dart';
import 'http_client.dart';

class CategorySpringService implements CategoryService {
  final AuthService authService;
  final Validator<Category, CategoryError> categoryValidator;
  final ApiHttpClient _httpClient;

  CategorySpringService({
    required this.authService,
    required this.categoryValidator,
    required SpringConfig config,
  }) : _httpClient = ApiHttpClient(baseUrl: '${config.url}/category');

  @override
  Future<DataPage<Category>> listCategories({
    List<String>? excludingCodes,
    int? page,
    int? pageSize,
  }) {
    try {
      return _httpClient.jsonGetPage<Category>(
        authService: authService,
        page: page,
        pageSize: pageSize,
        mapper: _SpringCategory.from,
      );
    } on SocketException catch (_) {
      throw NoServerError();
    }
  }

  @override
  Future<Category> saveCategory({
    String? code,
    required String name,
  }) async {
    final category = _SpringCategory()
      ..code = code ?? ''
      ..name = name;
    final errors = categoryValidator.validate(category);
    if (errors.isNotEmpty) {
      throw ValidationError(errors);
    }
    try {
      Map<String, dynamic> response;
      if (code != null) {
        response = await _httpClient.jsonPut<Map<String, dynamic>>(
          authService: authService,
          path: '/$code',
          data: category.toMap(),
        );
      } else {
        response = await _httpClient.jsonPost<Map<String, dynamic>>(
          authService: authService,
          data: category.toMap(),
        );
      }
      return _SpringCategory.from(response)!;
    } on SocketException catch (_) {
      throw NoServerError();
    } catch (e) {
      throw ValidationError({
        'category': CategoryError.invalidCategory,
      });
    }
  }

  @override
  Future<void> deleteCategory({required String code}) async {
    try {
      await _httpClient.delete(authService: authService, path: '/$code');
    } on SocketException catch (_) {
      throw NoServerError();
    } catch (e) {
      throw ValidationError({
        'category': CategoryError.invalidCategory,
      });
    }
  }

  @override
  Future<void> deleteCategories({required Set<String> codes}) async {
    if (codes.isEmpty) {
      return Future.value();
    }
    try {
      await _httpClient.delete(
          authService: authService, path: '/batch?codes=${codes.join(',')}');
    } on SocketException catch (_) {
      throw NoServerError();
    } catch (e) {
      throw ValidationError({
        'category': CategoryError.invalidCategory,
      });
    }
  }
}

class _SpringCategory implements Category {
  @override
  String code = '';

  @override
  String name = '';

  Map<String, Object> toMap() {
    return <String, Object>{
      codeField: code,
      nameField: name,
    };
  }

  static _SpringCategory? from(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final code = raw[codeField] as String?;
      final name = raw[nameField] as String?;
      if (code != null && name != null) {
        return _SpringCategory()
          ..code = code
          ..name = name;
      }
    }
    return null;
  }
}
