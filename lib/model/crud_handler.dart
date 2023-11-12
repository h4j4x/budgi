import 'package:flutter/material.dart';

import 'item_action.dart';

class CrudHandler<T> {
  VoidCallback reload = () {};

  Function(BuildContext, T, ItemAction) onItemAction;

  CrudHandler({
    required this.onItemAction,
  });
}
