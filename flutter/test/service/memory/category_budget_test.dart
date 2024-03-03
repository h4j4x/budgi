import 'dart:math';

import 'package:budgi/model/period.dart';
import 'package:budgi/model/sort.dart';
import 'package:budgi/service/memory/category_memory.dart';
import 'package:test/test.dart';

void main() {
  test('.saveCategory(), .listCategories(), .removeCategory()', () async {
    final service = CategoryMemoryService();

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

  test('.saveBudget(), .listBudgets(), .removeBudget()', () async {
    final service = CategoryMemoryService();

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
      final period = Period(from: fromDate, to: toDate);

      final amount = i.toDouble();
      final budget = await service.saveBudget(
        category: category,
        period: period,
        amount: amount,
      );
      expect(budget.category, equals(category));
      expect(budget.period.from, equals(fromDate));
      expect(budget.period.to, equals(toDate));
      expect(budget.amount, equals(amount));

      var list = await service.listBudgets(
        period: period,
      );
      expect(list.length, equals(1));

      await service.deleteBudget(
        category: category,
        period: period,
      );
      list = await service.listBudgets(
        period: period,
      );
      expect(list.length, equals(0));
    }
  });

  test('.listBudgets() with sort', () async {
    final service = CategoryMemoryService();

    final fromDate = DateTime.now();
    final toDate = fromDate.add(const Duration(days: 2));
    final period = Period(from: fromDate, to: toDate);

    final random = Random();
    for (var i = 0; i < 20; i++) {
      final name = 'category-$i';
      final category = await service.saveCategory(
        name: name,
      );

      final budget = await service.saveBudget(
        category: category,
        period: period,
        amount: random.nextDouble(),
      );
      expect(budget.category, equals(category));
    }

    // ASC
    var list = await service.listBudgets(
      period: period,
      budgetSort: Sort.asc,
    );
    var lastAmount = -1.0;
    for (var value in list) {
      expect(value.amount, greaterThanOrEqualTo(lastAmount));
      lastAmount = value.amount;
    }

    // DESC
    list = await service.listBudgets(
      period: period,
      budgetSort: Sort.desc,
    );
    lastAmount = double.infinity;
    for (var value in list) {
      expect(value.amount, lessThanOrEqualTo(lastAmount));
      lastAmount = value.amount;
    }
  });

  test('.saveBudget() with update', () async {
    final service = CategoryMemoryService();

    final category = await service.saveCategory(
      name: 'test',
    );

    final fromDate = DateTime.now();
    final toDate = fromDate.add(const Duration(days: 2));
    final period = Period(from: fromDate, to: toDate);

    final budget = await service.saveBudget(
      category: category,
      period: period,
      amount: 10.0,
    );
    expect(budget.category, equals(category));

    var list = await service.listBudgets(
      period: period,
    );
    expect(list.length, equals(1));

    const updatedAmount = 20.0;
    final updated = await service.saveBudget(
      category: category,
      period: period,
      amount: updatedAmount,
    );
    expect(updated.category, equals(category));
    expect(updated.amount, equals(updatedAmount));

    list = await service.listBudgets(
      period: period,
    );
    expect(list.length, equals(1));
    expect(list[0].amount, equals(updatedAmount));
  });

  test('Copies previous period budgets and save current', () async {
    final service = CategoryMemoryService();

    final category = await service.saveCategory(
      name: 'test',
    );

    final fromDate = DateTime.now();
    final toDate = fromDate.add(const Duration(days: 2));
    final period = Period(from: fromDate, to: toDate);

    var periodHasChanged = await service.periodHasChanged(period);
    expect(periodHasChanged, isFalse);

    final budget = await service.saveBudget(
      category: category,
      period: period,
      amount: 10.0,
    );

    periodHasChanged = await service.periodHasChanged(period);
    expect(periodHasChanged, isFalse);

    final newToDate = toDate.add(const Duration(days: 2));
    final newPeriod = Period(from: toDate, to: newToDate);
    periodHasChanged = await service.periodHasChanged(newPeriod);
    expect(periodHasChanged, isTrue);

    await service.copyPreviousPeriodBudgetsInto(newPeriod);
    final list = await service.listBudgets(
      period: newPeriod,
    );
    expect(list.length, equals(1));
    expect(list[0].category, equals(budget.category));
    expect(list[0].period, equals(newPeriod));
    expect(list[0].amount, equals(budget.amount));
  });
}
