import 'package:flutter/material.dart';

import '../sort.dart';

class CrudState<T> with ChangeNotifier {
  final _list = <T>[];

  final Future<List<T>> Function() loader;
  final Map<String, Object> _filters;
  final Map<String, Sort> _sorts;

  bool _loading = false;

  CrudState({
    required this.loader,
    Map<String, Object>? filters,
    Map<String, Sort>? sorts,
  })  : _filters = filters ?? {},
        _sorts = sorts ?? {} {
    load();
  }

  List<T> get list {
    return List.unmodifiable(_list);
  }

  Map<String, Object> get filters {
    return Map.unmodifiable(_filters);
  }

  Map<String, Sort> get sorts {
    return Map.unmodifiable(_sorts);
  }

  bool get loading {
    return _loading;
  }

  void setFilter(String key, Object? value) {
    if (value != null) {
      _filters[key] = value;
    } else {
      _filters.remove(key);
    }
    notifyListeners();
    load();
  }

  void setSort(String key, Sort? value) {
    if (value != null) {
      _sorts[key] = value;
    } else {
      _sorts.remove(key);
    }
    notifyListeners();
    load();
  }

  Future load() async {
    if (_loading) {
      return Future.value();
    }
    _loading = true;
    notifyListeners();

    final newList = await loader();
    _list.clear();
    _list.addAll(newList);
    _loading = false;
    notifyListeners();
  }
}
