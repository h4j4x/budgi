import 'dart:math';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
final _random = Random();

String randomString(int length) {
  final charCodes = Iterable.generate(length, (_) {
    return _chars.codeUnitAt(_random.nextInt(_chars.length));
  });
  return String.fromCharCodes(charCodes);
}
