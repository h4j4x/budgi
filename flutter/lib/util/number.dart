extension AppDouble on double {
  String get asMoneyString => '\$${toStringAsFixed(2)}';
}
