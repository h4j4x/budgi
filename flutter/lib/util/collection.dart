extension AppIterable<T> on Iterable<T> {
  Iterable<E> mapIndexed<E>(E Function(int index, T item) fn) sync* {
    var index = 0;
    for (final item in this) {
      yield fn(index, item);
      index += 1;
    }
  }
}

extension AppSet<T> on Set<T> {
  // Add the items if not contained, remove it if exists.
  void xAdd(T item) {
    if (contains(item)) {
      remove(item);
    } else {
      add(item);
    }
  }
}
