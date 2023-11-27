import '../../di.dart';
import '../../model/domain/category.dart';
import '../../model/domain/user.dart';
import '../../model/error/category_error.dart';
import '../../model/error/validation.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../util/collection.dart';
import '../../util/string.dart';
import '../auth.dart';
import '../category.dart';
import '../validator.dart';
import '../vendor/supabase.dart';

const categoryTable = 'categories';

class CategorySupabaseService implements CategoryService {
  final SupabaseConfig config;
  final Validator<Category, CategoryError>? categoryValidator;
  final Validator<CategoryAmount, CategoryError>? amountValidator;

  CategorySupabaseService({
    required this.config,
    this.categoryValidator,
    this.amountValidator,
  });

  @override
  Future<Category> saveCategory({
    String? code,
    required String name,
  }) async {
    final categoryCode = code ?? randomString(6);
    final category = _Category(categoryCode, name);
    final errors = categoryValidator?.validate(category);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError<CategoryError>(errors!);
    }

    final user = DI().get<AuthService>().user();
    if (user == null) {
      throw ValidationError<CategoryError>({
        'user': CategoryError.invalidUser,
      });
    }
    await config.supabase.from(categoryTable).insert(category.toMap(user)).select();
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

    final data = await config.supabase.from(categoryTable).select('$codeField, $nameField').eq(userIdField, user.id);
    if (data is List) {
      return data
          .map((item) {
            return _Category.from(item);
          })
          .toNonNull<Category>()
          .toList();
    }
    return [];

    // final list = _categories.values.toList();
    // if (period != null) {
    //   final amountsCategories =
    //       (_values[period.toString()] ?? <CategoryAmount>{}).map((amount) => amount.category.code).toList();
    //   list.removeWhere((category) {
    //     final match = amountsCategories.contains(category.code);
    //     if (withAmount) {
    //       return !match;
    //     }
    //     return match;
    //   });
    // }
    // return Future.value(list);
  }

  @override
  Future<void> deleteCategory({
    required String code,
  }) {
    // _categories.remove(code);
    return Future.value();
  }

  @override
  Future<CategoryAmount> saveAmount({
    required String categoryCode,
    String? amountCode,
    required Period period,
    required double amount,
  }) {
    // _saveLastUsed(period);
    //
    // final category = _categories[categoryCode];
    // if (category == null) {
    //   throw ValidationError({
    //     'category': CategoryError.invalidCategory,
    //   });
    // }
    // final categoryAmount = _CategoryAmount(category, period, amount);
    // final errors = amountValidator?.validate(categoryAmount);
    // if (errors?.isNotEmpty ?? false) {
    //   throw ValidationError(errors!);
    // }
    //
    // final periodKey = period.toString();
    // _values[periodKey] ??= <CategoryAmount>{};
    // _values[periodKey]!.removeWhere((amount) => amount.category.code == category.code);
    // _values[periodKey]!.add(categoryAmount);
    return Future.value();
  }

  @override
  Future<List<CategoryAmount>> listAmounts({
    required Period period,
    Sort? amountSort,
  }) {
    // _saveLastUsed(period);
    //
    // final set = _values[period.toString()] ?? {};
    // return Future.value(set.toList()
    //   ..sort(
    //     (value1, value2) {
    //       if (amountSort == Sort.asc) {
    //         return value1.amount.compareTo(value2.amount);
    //       }
    //       if (amountSort == Sort.desc) {
    //         return value2.amount.compareTo(value1.amount);
    //       }
    //       return 0;
    //     },
    //   ));
    return Future.value([]);
  }

  @override
  Future<void> deleteAmount({
    required String categoryCode,
    required Period period,
  }) {
    // _saveLastUsed(period);
    //
    // final set = _values[period.toString()] ?? {};
    // set.removeWhere((amount) => amount.category.code == categoryCode);
    return Future.value();
  }

  // void _saveLastUsed(Period period) {
  //   final periodKey = period.toString();
  //   if (!_periods.contains(periodKey)) {
  //     _periods.add(periodKey);
  //   }
  // }

  @override
  Future<bool> periodHasChanged(Period period) {
    // if (_periods.isNotEmpty) {
    //   final periodKey = period.toString();
    //   return Future.value(!_periods.contains(periodKey));
    // }
    return Future.value(false);
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
}

const userIdField = 'user_id';
const codeField = 'code';
const nameField = 'name';

class _Category implements Category {
  _Category(this.code, this.name);

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
    if (raw is Map<String, dynamic>) {
      final code = raw[codeField] as String?;
      final name = raw[nameField] as String?;
      if (code != null && name != null) {
        return _Category(code, name);
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

class _CategoryAmount implements CategoryAmount {
  _CategoryAmount(this.category, this.period, this.amount);

  @override
  Category category;

  @override
  Period period;

  @override
  double amount;

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
    return _CategoryAmount(category, period, amount);
  }
}
