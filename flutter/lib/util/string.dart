import 'dart:math';

import 'collection.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
final _random = Random();

String randomString(int length) {
  final charCodes = Iterable.generate(length, (_) {
    return _chars.codeUnitAt(_random.nextInt(_chars.length));
  });
  return String.fromCharCodes(charCodes);
}

extension StringExtension on String {
  String toCamelCase() {
    final parts = split('_');
    return parts.mapIndexed((index, part) {
      if (index == 0 || part.isEmpty) {
        return part;
      }
      return part[0].toUpperCase() + part.substring(1);
    }).join();
  }
}
