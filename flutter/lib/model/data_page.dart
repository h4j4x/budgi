import 'dart:math';

import 'fetch_mode.dart';

class DataPage<T> {
  List<T> content;
  int pageNumber;
  int pageSize;
  int totalElements;
  int totalPages;

  int _nextPageStep = 1;

  DataPage({
    required this.content,
    this.pageNumber = -1,
    int? pageSize,
    int? totalElements,
    int? totalPages,
  })  : pageSize = pageSize ?? content.length,
        totalElements = totalElements ?? content.length,
        totalPages = totalPages ?? pageNumber + 1;

  bool get isEmpty {
    return content.isEmpty;
  }

  int get length {
    return content.length;
  }

  bool get hasNextPage {
    return totalPages > pageNumber + 1;
  }

  int get nextPageNumber {
    final nextPage = pageNumber + _nextPageStep;
    _nextPageStep = 1;
    return nextPage;
  }

  void add(DataPage<T> dataPage) {
    if (pageNumber < dataPage.pageNumber) {
      content.addAll(dataPage.content);
      pageNumber = dataPage.pageNumber;
    } else {
      final offset = dataPage.pageNumber * pageSize;
      final limit = min(offset + pageSize, content.length);
      content.replaceRange(offset, limit, dataPage.content);
    }
    pageSize = dataPage.pageSize;
    totalElements = dataPage.totalElements;
    totalPages = dataPage.totalPages;
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
      pageNumber = -1;
      totalElements = 0;
      totalPages = 0;
      _nextPageStep = 1;
    } else if (fetchMode == FetchMode.refreshPage) {
      _nextPageStep = 0;
    } else if (fetchMode == FetchMode.nextPage) {
      _nextPageStep = 1;
    }
  }

  bool indexIsLastPageItem(int index) {
    return (index + 1) % pageSize == 0;
  }

  int pageNumberOfIndex(int index) {
    return (index ~/ pageSize) + 1;
  }
}
