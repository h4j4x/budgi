import 'package:budgi/util/datetime.dart';
import 'package:test/test.dart';

void main() {
  test('toDateTimeString() returns offset datetime representation', () {
    var datetime = DateTime.utc(2024, 3, 25, 18, 42, 10, 10, 20);
    expect('2024-03-25T18:42:10+00:00', equals(datetime.toDateTimeString()));
  });
}
