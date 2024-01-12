import 'dart:math';

import 'package:budgi/util/string.dart';
import 'package:test/test.dart';

void main() {
  test('randomString() returns random string with given length', () {
    final random = Random();
    for (var i = 0; i < 10; i++) {
      final length = random.nextInt(50) + 10;
      final string = randomString(length);
      expect(string.trim().length, equals(length));
    }
  });

  test('toCamelCase() converts from Snake Case', () {
    final pairs = <String, String>{
      'number_of_donuts': 'numberOfDonuts',
      'fave_phrase': 'favePhrase',
    };
    for (var entry in pairs.entries) {
      final camelCase = entry.key.toCamelCase();
      expect(camelCase, equals(entry.value));
    }
  });
}
