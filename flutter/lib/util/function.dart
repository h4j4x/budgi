import 'package:flutter/material.dart';

import '../model/item_action.dart';

typedef TypedCallback<T> = void Function(T value);

typedef TypedFutureFetcher<T, E> = Future<T?> Function(E value);

typedef TypedContextItemAction<T> = void Function(BuildContext, T, ItemAction);
