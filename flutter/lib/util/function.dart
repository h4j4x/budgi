import 'package:flutter/material.dart';

import '../model/item_action.dart';

typedef TypedCallback<T> = void Function(T value);

typedef TypedFutureFetcher<T, E> = Future<T?> Function(E value);

class CrudHandler<T> {
  VoidCallback reload = () {};

  Function(BuildContext, T, ItemAction) onItemAction;

  CrudHandler({
    required this.onItemAction,
  });
}
