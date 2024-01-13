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
}
