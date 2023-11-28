import 'dart:math';

import 'package:budgi/model/period.dart';
import 'package:budgi/model/sort.dart';
import 'package:budgi/service/impl/category_memory.dart';
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

  test('.listCategories() with amounts filter', () async {
    final service = CategoryMemoryService();

    final category1 = await service.saveCategory(name: 'cat1');
    final category2 = await service.saveCategory(name: 'cat2');

    final fromDate = DateTime.now();
    final toDate = fromDate.add(const Duration(days: 2));
    final period = Period(from: fromDate, to: toDate);

    await service.saveAmount(
      categoryCode: category1.code,
      period: period,
      amount: 1,
    );
    var list = await service.listCategories();
    expect(list.length, equals(2));

    // WITH AMOUNTS
    list = await service.listCategories(
      withAmount: true,
      period: period,
    );
    expect(list.length, equals(1));
    expect(list[0].code, equals(category1.code));

    // WITHOUT AMOUNTS
    list = await service.listCategories(
      withAmount: false,
      period: period,
    );
    expect(list.length, equals(1));
    expect(list[0].code, equals(category2.code));
  });

  test('.saveAmount(), .listAmounts(), .removeAmount()', () async {
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
      final categoryAmount = await service.saveAmount(
        categoryCode: category.code,
        period: period,
        amount: amount,
      );
      expect(categoryAmount.category, equals(category));
      expect(categoryAmount.period.from, equals(fromDate));
      expect(categoryAmount.period.to, equals(toDate));
      expect(categoryAmount.amount, equals(amount));

      var list = await service.listAmounts(
        period: period,
      );
      expect(list.length, equals(1));

      await service.deleteAmount(
        categoryCode: category.code,
        period: period,
      );
      list = await service.listAmounts(
        period: period,
      );
      expect(list.length, equals(0));
    }
  });

  test('.listAmounts() with sort', () async {
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

      final categoryAmount = await service.saveAmount(
        categoryCode: category.code,
        period: period,
        amount: random.nextDouble(),
      );
      expect(categoryAmount.category, equals(category));
    }

    // ASC
    var list = await service.listAmounts(
      period: period,
      amountSort: Sort.asc,
    );
    var lastAmount = -1.0;
    for (var value in list) {
      expect(value.amount, greaterThanOrEqualTo(lastAmount));
      lastAmount = value.amount;
    }

    // DESC
    list = await service.listAmounts(
      period: period,
      amountSort: Sort.desc,
    );
    lastAmount = double.infinity;
    for (var value in list) {
      expect(value.amount, lessThanOrEqualTo(lastAmount));
      lastAmount = value.amount;
    }
  });

  test('.saveAmount() with update', () async {
    final service = CategoryMemoryService();

    final category = await service.saveCategory(
      name: 'test',
    );

    final fromDate = DateTime.now();
    final toDate = fromDate.add(const Duration(days: 2));
    final period = Period(from: fromDate, to: toDate);

    final categoryAmount = await service.saveAmount(
      categoryCode: category.code,
      period: period,
      amount: 10.0,
    );
    expect(categoryAmount.category, equals(category));

    var list = await service.listAmounts(
      period: period,
    );
    expect(list.length, equals(1));

    const updatedAmount = 20.0;
    final updated = await service.saveAmount(
      categoryCode: category.code,
      period: period,
      amount: updatedAmount,
    );
    expect(updated.category, equals(category));
    expect(updated.amount, equals(updatedAmount));

    list = await service.listAmounts(
      period: period,
    );
    expect(list.length, equals(1));
    expect(list[0].amount, equals(updatedAmount));
  });

  test('Copies previous period amounts and save current', () async {
    final service = CategoryMemoryService();

    final category = await service.saveCategory(
      name: 'test',
    );

    final fromDate = DateTime.now();
    final toDate = fromDate.add(const Duration(days: 2));
    final period = Period(from: fromDate, to: toDate);

    var periodHasChanged = await service.periodHasChanged(period);
    expect(periodHasChanged, isFalse);

    final categoryAmount = await service.saveAmount(
      categoryCode: category.code,
      period: period,
      amount: 10.0,
    );

    periodHasChanged = await service.periodHasChanged(period);
    expect(periodHasChanged, isFalse);

    final newToDate = toDate.add(const Duration(days: 2));
    final newPeriod = Period(from: toDate, to: newToDate);
    periodHasChanged = await service.periodHasChanged(newPeriod);
    expect(periodHasChanged, isTrue);

    await service.copyPreviousPeriodAmountsInto(newPeriod);
    final list = await service.listAmounts(
      period: newPeriod,
    );
    expect(list.length, equals(1));
    expect(list[0].category, equals(categoryAmount.category));
    expect(list[0].period, equals(newPeriod));
    expect(list[0].amount, equals(categoryAmount.amount));
  });
}
