extension AppIterable<T> on Iterable<T> {
  Iterable<E> mapIndexed<E>(E Function(int index, T item) fn) sync* {
    var index = 0;
    for (final item in this) {
      yield fn(index, item);
      index += 1;
    }
  }
}
