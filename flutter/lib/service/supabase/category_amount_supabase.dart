import 'package:supabase_flutter/supabase_flutter.dart';

import '../../di.dart';
import '../../model/domain/category.dart';
import '../../model/domain/category_amount.dart';
import '../../model/domain/user.dart';
import '../../model/error/category.dart';
import '../../model/error/validation.dart';
import '../../model/fields.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../util/function.dart';
import '../auth.dart';
import '../category.dart';
import '../category_amount.dart';
import '../storage.dart';
import '../validator.dart';
import 'supabase.dart';
import 'category_supabase.dart';

const lastUsedPeriodKey = 'last_used_period';

class CategoryAmountSupabaseService implements CategoryAmountService {
  final SupabaseConfig config;
  final StorageService storageService;
  final Validator<CategoryAmount, CategoryError>? amountValidator;

  CategoryAmountSupabaseService({
    required this.config,
    required this.storageService,
    this.amountValidator,
  });

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

    final categoryAmount =
        _CategoryAmount(category: category, period: period, amount: amount);
    final errors = amountValidator?.validate(categoryAmount);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError(errors!);
    }

    final categoryAmountExists =
        await _categoryAmountExistsByCategoryAndPeriod(category, period);
    if (categoryAmountExists) {
      await config.supabase
          .from(categoryAmountTable)
          .update(categoryAmount.toMap(user))
          .match({
        categoryIdField: category.id,
        fromDateField: period.from.toIso8601String(),
        toDateField: period.to.toIso8601String(),
      });
    } else {
      await config.supabase
          .from(categoryAmountTable)
          .insert(categoryAmount.toMap(user));
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
        return _CategoryAmount.from(item, _fetchCategoryById);
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

  Future<bool> _categoryAmountExistsByCategoryAndPeriod(
      SupabaseCategory category, Period period) async {
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

  AppUser _fetchUser() {
    final user = DI().get<AuthService>().user();
    if (user != null) {
      return user;
    }
    throw ValidationError<CategoryError>({
      'user': CategoryError.invalidUser,
    });
  }

  Future<SupabaseCategory> _fetchCategoryByCode(String code) async {
    final category =
        await DI().get<CategoryService>().fetchCategoryByCode(code);
    if (category is SupabaseCategory) {
      return category;
    }
    throw ValidationError({
      'category': CategoryError.invalidCategory,
    });
  }

  Future<SupabaseCategory?> _fetchCategoryById(int id) async {
    final category = await DI().get<CategoryService>().fetchCategoryById(id);
    if (category is SupabaseCategory) {
      return category;
    }
    return null;
  }
}

class _CategoryAmount implements CategoryAmount {
  final int id;
  final SupabaseCategory _category;

  _CategoryAmount({
    this.id = 0,
    required SupabaseCategory category,
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

  static Future<_CategoryAmount?> from(
      dynamic raw, TypedFutureFetcher<SupabaseCategory, int> fetcher) async {
    if (raw is Map<String, dynamic>) {
      final id = raw[idField] as int?;
      final categoryId = raw[categoryIdField] as int?;
      final fromDate = DateTime.tryParse((raw[fromDateField] as String?) ?? '');
      final toDate = DateTime.tryParse((raw[toDateField] as String?) ?? '');
      final amount = raw[amountField] as num?;
      if (id != null &&
          categoryId != null &&
          fromDate != null &&
          toDate != null &&
          amount != null) {
        final category = await fetcher(categoryId);
        if (category != null) {
          final period = Period(from: fromDate, to: toDate);
          return _CategoryAmount(
              id: id,
              category: category,
              period: period,
              amount: amount.toDouble());
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
    return other is _CategoryAmount &&
        runtimeType == other.runtimeType &&
        category == other.category;
  }

  @override
  int get hashCode {
    return category.code.hashCode;
  }

  @override
  CategoryAmount copyWith({required Period period}) {
    return _CategoryAmount(
        id: id, category: _category, period: period, amount: amount);
  }
}
