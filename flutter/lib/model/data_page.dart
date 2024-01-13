import 'dart:math';

import 'fetch_mode.dart';

class DataPage<T> {
  List<T> content;
  int pageNumber;
  int pageSize;
  int totalElements;

  DataPage({
    required this.content,
    this.pageNumber = -1,
    int? pageSize,
    int? totalElements,
  })  : pageSize = pageSize ?? content.length,
        totalElements = totalElements ?? content.length;

  bool get isEmpty {
    return content.isEmpty;
  }

  int get length {
    return content.length;
  }

  void add(DataPage<T> dataPage) {
    if (pageNumber < dataPage.pageNumber) {
      content.addAll(dataPage.content);
      pageNumber = dataPage.pageNumber;
    } else if (pageNumber > dataPage.pageNumber) {
      content.insertAll(0, dataPage.content);
    } else if (pageNumber == dataPage.pageNumber) {
      for (var element in dataPage.content) {
        final index = content.indexOf(element);
        if (index >= 0) {
          content.removeAt(index);
          content.insert(index, element);
        } else {
          content.add(element);
        }
      }
    }
    pageSize = dataPage.pageSize;
    totalElements = dataPage.totalElements;
  }

  T operator [](int index) {
    return content[index];
  }

  static DataPage<T> empty<T>() {
    return DataPage<T>(content: <T>[]);
  }

  void apply(FetchMode fetchMode) {
    if (fetchMode == FetchMode.clear) {
      content.clear();
      pageNumber = 0;
      totalElements = 0;
    } else if (fetchMode == FetchMode.refreshPage) {
      pageNumber = 0;
      pageSize = max(content.length, 20);
    } else if (fetchMode == FetchMode.nextPage) {
      pageNumber += 1;
    }
  }
}
