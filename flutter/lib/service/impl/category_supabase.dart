import 'package:supabase_flutter/supabase_flutter.dart';

import '../../di.dart';
import '../../model/domain/category.dart';
import '../../model/domain/user.dart';
import '../../model/error/category.dart';
import '../../model/error/validation.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../util/string.dart';
import '../auth.dart';
import '../category.dart';
import '../storage.dart';
import '../validator.dart';
import '../vendor/supabase.dart';

const categoryTable = 'categories';
const categoryAmountTable = 'categories_amounts';

const lastUsedPeriodKey = 'last_used_period';

class CategorySupabaseService implements CategoryService {
  final SupabaseConfig config;
  final StorageService storageService;
  final Validator<Category, CategoryError>? categoryValidator;
  final Validator<CategoryAmount, CategoryError>? amountValidator;

  CategorySupabaseService({
    required this.config,
    required this.storageService,
    this.categoryValidator,
    this.amountValidator,
  });

  @override
  Future<Category> saveCategory({
    String? code,
    required String name,
  }) async {
    final user = _fetchUser();

    final categoryCode = code ?? randomString(6);
    final category = _Category(code: categoryCode, name: name);
    final errors = categoryValidator?.validate(category);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError<CategoryError>(errors!);
    }

    final categoryExists = await _categoryExistsByCode(categoryCode);
    if (categoryExists) {
      await config.supabase.from(categoryTable).update(category.toMap(user)).match({codeField: categoryCode});
    } else {
      await config.supabase.from(categoryTable).insert(category.toMap(user));
    }
    return category;
  }

  @override
  Future<List<Category>> listCategories({
    bool withAmount = false,
    Period? period,
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

    final data = await query;
    if (data is List) {
      return data.map(_Category.from).whereType<Category>().toList();
    }
    return [];
  }

  @override
  Future<void> deleteCategory({
    required String code,
  }) async {
    await config.supabase.from(categoryTable).delete().match({codeField: code});
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

  @override
  Future<CategoryAmount> saveAmount({
    required String categoryCode,
    String? amountCode,
    required Period period,
    required double amount,
  }) async {
    _saveLastUsed(period);

    final user = _fetchUser();
    final category = await _fetchCategoryByCode(categoryCode);

    final categoryAmount = _CategoryAmount(category: category, period: period, amount: amount);
    final errors = amountValidator?.validate(categoryAmount);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    final categoryAmountExists = await _categoryAmountExistsByCategoryAndPeriod(category, period);
    if (categoryAmountExists) {
      await config.supabase.from(categoryAmountTable).update(categoryAmount.toMap(user)).match({
        categoryIdField: category.id,
        fromDateField: period.from.toIso8601String(),
        toDateField: period.to.toIso8601String(),
      });
    } else {
      await config.supabase.from(categoryAmountTable).insert(categoryAmount.toMap(user));
    }
    return categoryAmount;
  }

  @override
  Future<List<CategoryAmount>> listAmounts({
    required Period period,
    Sort? amountSort,
  }) async {
    _saveLastUsed(period);

    final user = DI().get<AuthService>().user();
    if (user == null) {
      return [];
    }

    final query = config.supabase
        .from(categoryAmountTable)
        .select()
        .eq(userIdField, user.id)
        .eq(fromDateField, period.from.toIso8601String())
        .eq(toDateField, period.to.toIso8601String());
    dynamic data;
    if (amountSort != null) {
      data = await query.order(amountField, ascending: amountSort == Sort.asc);
    } else {
      data = await query;
    }

    if (data is List) {
      final futureList = data.map((item) {
        return _CategoryAmount.from(
          item,
          (id) async {
            final categoryData = await config.supabase.from(categoryTable).select().eq(idField, id);
            return _Category.from(categoryData);
          },
        );
      });
      final list = await Future.wait(futureList);
      return list.whereType<CategoryAmount>().toList();
    }
    return [];
  }

  @override
  Future<void> deleteAmount({
    required String categoryCode,
    required Period period,
  }) async {
    _saveLastUsed(period);

    final category = await _fetchCategoryByCode(categoryCode);
    await config.supabase.from(categoryAmountTable).delete().match({
      categoryIdField: category.id,
      fromDateField: period.from.toIso8601String(),
      toDateField: period.to.toIso8601String(),
    });
  }

  @override
  Future<bool> periodHasChanged(Period period) async {
    final periodKey = period.toString();
    final savedKey = await storageService.readString(lastUsedPeriodKey);
    return periodKey != savedKey;
  }

  @override
  Future copyPreviousPeriodAmountsInto(Period period) {
    // if (_periods.isNotEmpty) {
    //   final previousPeriodKey = _periods.last;
    //   final periodKey = period.toString();
    //   _values[periodKey] = <CategoryAmount>{};
    //   for (var categoryAmount in _values[previousPeriodKey]!) {
    //     _values[periodKey]!.add(categoryAmount.copyWith(period: period));
    //   }
    // }
    return Future.value();
  }

  @override
  Future<Map<CategoryAmount, double>> categoriesTransactionsTotal({
    required Period period,
    bool expensesTransactions = true,
    bool showZeroTotal = false,
  }) async {
    // final transactionTypes = TransactionType.values.where((type) {
    //   if (expensesTransactions) {
    //     return !type.isIncome;
    //   }
    //   return type.isIncome;
    // }).toList();
    // final transactions = await DI().get<TransactionService>().listTransactions(
    //       transactionTypes: transactionTypes,
    //       period: period,
    //       dateTimeSort: Sort.asc,
    //     );
    // final map = <CategoryAmount, double>{};
    // final amounts = _values[period.toString()] ?? {};
    // for (var transaction in transactions) {
    //   final categoryAmount = amounts.where((amount) => amount.category == transaction.category).toList();
    //   if (categoryAmount.length == 1) {
    //     map[categoryAmount.first] = (map[categoryAmount.first] ?? 0) + transaction.signedAmount;
    //   }
    // }
    // if (showZeroTotal) {
    //   for (var categoryAmount in amounts) {
    //     map[categoryAmount] ??= 0;
    //   }
    // }
    return Future.value({});
  }

  void _saveLastUsed(Period period) {
    storageService.writeString(lastUsedPeriodKey, period.toString());
  }

  Future<bool> _categoryAmountExistsByCategoryAndPeriod(_Category category, Period period) async {
    final count = await config.supabase
        .from(categoryAmountTable)
        .select(
          idField,
          const FetchOptions(
            count: CountOption.exact,
          ),
        )
        .eq(categoryIdField, category.id)
        .eq(fromDateField, period.from.toIso8601String())
        .eq(toDateField, period.to.toIso8601String());
    return count.count != null && count.count! > 0;
  }

  Future<_Category> _fetchCategoryByCode(String code) async {
    final categoryData = await config.supabase.from(categoryTable).select().eq(codeField, code);
    final category = _Category.from(categoryData);
    if (category != null) {
      return category;
    }
    throw ValidationError({
      'category': CategoryError.invalidCategory,
    });
  }

  Future<List<int>> _fetchCategoriesIdsOfAmounts(String userId, Period period) async {
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

  AppUser _fetchUser() {
    final user = DI().get<AuthService>().user();
    if (user != null) {
      return user;
    }
    throw ValidationError<CategoryError>({
      'user': CategoryError.invalidUser,
    });
  }
}

typedef _CategoryFetcher = Future<_Category?> Function(int);

const idField = 'id';
const userIdField = 'user_id';
const codeField = 'code';
const nameField = 'name';

class _Category implements Category {
  final int id;

  _Category({
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

  static _Category? from(dynamic raw) {
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
        return _Category(id: id, code: code, name: name);
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _Category && runtimeType == other.runtimeType && code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}

const categoryIdField = 'category_id';
const fromDateField = 'from_date';
const toDateField = 'to_date';
const amountField = 'amount';

class _CategoryAmount implements CategoryAmount {
  final int id;
  final _Category _category;

  _CategoryAmount({
    this.id = 0,
    required _Category category,
    required this.period,
    required this.amount,
  }) : _category = category;

  @override
  Category get category {
    return _category;
  }

  @override
  Period period;

  @override
  double amount;

  Map<String, Object> toMap(AppUser user) {
    return <String, Object>{
      userIdField: user.id,
      categoryIdField: _category.id,
      fromDateField: period.from.toIso8601String(),
      toDateField: period.to.toIso8601String(),
      amountField: amount,
    };
  }

  static Future<_CategoryAmount?> from(dynamic raw, _CategoryFetcher fetcher) async {
    if (raw is Map<String, dynamic>) {
      final id = raw[idField] as int?;
      final categoryId = raw[categoryIdField] as int?;
      final fromDate = DateTime.tryParse((raw[fromDateField] as String?) ?? '');
      final toDate = DateTime.tryParse((raw[toDateField] as String?) ?? '');
      final amount = raw[amountField] as num?;
      if (id != null && categoryId != null && fromDate != null && toDate != null && amount != null) {
        final category = await fetcher(categoryId);
        if (category != null) {
          final period = Period(from: fromDate, to: toDate);
          return _CategoryAmount(id: id, category: category, period: period, amount: amount.toDouble());
        }
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _CategoryAmount && runtimeType == other.runtimeType && category == other.category;
  }

  @override
  int get hashCode {
    return category.code.hashCode;
  }

  @override
  CategoryAmount copyWith({required Period period}) {
    return _CategoryAmount(id: id, category: _category, period: period, amount: amount);
  }
}
