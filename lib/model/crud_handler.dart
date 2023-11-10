import 'package:flutter/material.dart';

class CrudHandler<T> {
  VoidCallback reload = () {};

  Function(BuildContext, T) onItemAction;

  CrudHandler({
    required this.onItemAction,
  });
}
