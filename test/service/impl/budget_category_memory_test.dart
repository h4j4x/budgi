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

      await service.removeAmount(category.budgetCategory.code);
      list = await service.listAmounts(
        fromDate: fromDate,
        toDate: toDate,
      );
      expect(list.length, equals(0));
    }
  });
}
