import 'dart:math';

import 'package:budgi/model/sort.dart';
import 'package:budgi/service/impl/budget_category_memory.dart';
import 'package:test/test.dart';

void main() {
  test('.saveCategory(), .listCategories(), .removeCategory()', () async {
    final service = BudgetCategoryMemoryService();

    const total = 10;
    var lastCode = '';
    for (var i = 1; i <= total; i++) {
      final name = 'category-$i';
      final category = await service.saveCategory(
        name: name,
      );
      expect(category.code, isNotEmpty);
      expect(category.name, equals(name));

      final list = await service.listCategories();
      expect(list.length, equals(i));

      lastCode = category.code;
    }

    expect(lastCode, isNotEmpty);
    await service.deleteCategory(
      code: lastCode,
    );
    final list = await service.listCategories();
    expect(list.length, equals(total - 1));
  });

  test('.saveAmount(), .listAmounts(), .removeAmount()', () async {
    final service = BudgetCategoryMemoryService();

    final startDate = DateTime.now();
    const daysDiff = 2;
    const totalDays = 10;
    for (var i = 1; i <= totalDays; i++) {
      final name = 'category-$i';
      final category = await service.saveCategory(
        name: name,
      );

      final fromDate = startDate.add(Duration(days: i));
      final toDate = fromDate.add(const Duration(days: daysDiff));
      final amount = i.toDouble();
      final categoryAmount = await service.saveAmount(
        categoryCode: category.code,
        fromDate: fromDate,
        toDate: toDate,
        amount: amount,
      );
      expect(categoryAmount.category, equals(category));
      expect(categoryAmount.fromDate, equals(fromDate));
      expect(categoryAmount.toDate, equals(toDate));
      expect(categoryAmount.amount, equals(amount));

      var list = await service.listAmounts(
        fromDate: fromDate,
        toDate: toDate,
      );
      expect(list.length, equals(1));

      await service.deleteAmount(
        categoryCode: category.code,
        fromDate: fromDate,
        toDate: toDate,
      );
      list = await service.listAmounts(
        fromDate: fromDate,
        toDate: toDate,
      );
      expect(list.length, equals(0));
    }
  });

  test('.listAmounts() with sort', () async {
    final service = BudgetCategoryMemoryService();

    final fromDate = DateTime.now();
    final toDate = DateTime.now()..add(const Duration(days: 2));
    final random = Random();
    for (var i = 0; i < 20; i++) {
      final name = 'category-$i';
      final category = await service.saveCategory(
        name: name,
      );

      final categoryAmount = await service.saveAmount(
        categoryCode: category.code,
        fromDate: fromDate,
        toDate: toDate,
        amount: random.nextDouble(),
      );
      expect(categoryAmount.category, equals(category));
    }

    // ASC
    var list = await service.listAmounts(
      fromDate: fromDate,
      toDate: toDate,
      amountSort: Sort.asc,
    );
    var lastAmount = -1.0;
    for (var value in list) {
      expect(value.amount, greaterThanOrEqualTo(lastAmount));
      lastAmount = value.amount;
    }

    // DESC
    list = await service.listAmounts(
      fromDate: fromDate,
      toDate: toDate,
      amountSort: Sort.desc,
    );
    lastAmount = double.infinity;
    for (var value in list) {
      expect(value.amount, lessThanOrEqualTo(lastAmount));
      lastAmount = value.amount;
    }
  });

  test('.saveAmount() with update', () async {
    final service = BudgetCategoryMemoryService();

    final category = await service.saveCategory(
      name: 'test',
    );

    final fromDate = DateTime.now();
    final toDate = DateTime.now()..add(const Duration(days: 2));
    final categoryAmount = await service.saveAmount(
      categoryCode: category.code,
      fromDate: fromDate,
      toDate: toDate,
      amount: 10.0,
    );
    expect(categoryAmount.category, equals(category));

    var list = await service.listAmounts(
      fromDate: fromDate,
      toDate: toDate,
    );
    expect(list.length, equals(1));

    const updatedAmount = 20.0;
    final updated = await service.saveAmount(
      categoryCode: category.code,
      fromDate: fromDate,
      toDate: toDate,
      amount: updatedAmount,
    );
    expect(updated.category, equals(category));
    expect(updated.amount, equals(updatedAmount));

    list = await service.listAmounts(
      fromDate: fromDate,
      toDate: toDate,
    );
    expect(list.length, equals(1));
    expect(list[0].amount, equals(updatedAmount));
  });
}
