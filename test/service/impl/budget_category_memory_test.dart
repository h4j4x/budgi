import 'dart:math';

import 'package:budgi/model/sort.dart';
import 'package:budgi/service/impl/budget_category_memory.dart';
import 'package:test/test.dart';

void main() {
  test('.saveAmount(), .listAmounts(), .removeAmount()', () async {
    final service = BudgetCategoryMemoryService();

    final startDate = DateTime.now();
    const daysDiff = 2;
    const totalDays = 10;
    for (var i = 1; i <= totalDays; i++) {
      final name = 'category-$i';
      final fromDate = startDate.add(Duration(days: i));
      final toDate = fromDate.add(const Duration(days: daysDiff));
      final amount = i.toDouble();
      final category = await service.saveAmount(
        categoryName: name,
        fromDate: fromDate,
        toDate: toDate,
        amount: amount,
      );
      expect(category.budgetCategory.code, isNotEmpty);
      expect(category.budgetCategory.name, equals(name));
      expect(category.fromDate, equals(fromDate));
      expect(category.toDate, equals(toDate));
      expect(category.amount, equals(amount));

      var list = await service.listAmounts(
        fromDate: fromDate,
        toDate: toDate,
      );
      expect(list.length, equals(1));

      await service.deleteAmount(
        code: category.budgetCategory.code,
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
      final category = await service.saveAmount(
        categoryName: name,
        fromDate: fromDate,
        toDate: toDate,
        amount: random.nextDouble(),
      );
      expect(category.budgetCategory.code, isNotEmpty);
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

    final fromDate = DateTime.now();
    final toDate = DateTime.now()..add(const Duration(days: 2));
    final category = await service.saveAmount(
      categoryName: 'test',
      fromDate: fromDate,
      toDate: toDate,
      amount: 10.0,
    );
    expect(category.budgetCategory.code, isNotEmpty);

    var list = await service.listAmounts(
      fromDate: fromDate,
      toDate: toDate,
    );
    expect(list.length, equals(1));

    final updatedName = '${category.budgetCategory.name}-updated';
    final updated = await service.saveAmount(
      categoryCode: category.budgetCategory.code,
      categoryName: updatedName,
      fromDate: fromDate,
      toDate: toDate,
      amount: 20.0,
    );
    expect(updated.budgetCategory.code, equals(category.budgetCategory.code));
    expect(updated.budgetCategory.name, equals(updatedName));

    list = await service.listAmounts(
      fromDate: fromDate,
      toDate: toDate,
    );
    expect(list.length, equals(1));
  });
}
