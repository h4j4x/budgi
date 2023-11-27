import '../period.dart';

abstract class Category {
  String get code;

  String get name;
}

abstract class CategoryAmount {
  Category get category;

  Period get period;

  double get amount;

  CategoryAmount copyWith({required Period period});
}

class CategoryAmountData extends Period {
  final CategoryAmount? amount;

  CategoryAmountData({
    this.amount,
    required super.from,
    required super.to,
  });

  factory CategoryAmountData.fromPeriod({
    CategoryAmount? amount,
    required Period period,
  }) {
    return CategoryAmountData(
      amount: amount,
      from: period.from,
      to: period.to,
    );
  }
}
