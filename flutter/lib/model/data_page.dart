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

  int get pageLength {
    final offset = pageNumber * pageSize;
    final limit = min(offset + pageSize, content.length);
    return limit - offset;
  }

  List<T> get pageContent {
    final offset = pageNumber * pageSize;
    final limit = min(offset + pageSize, content.length);
    return content.sublist(offset, limit);
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

  void apply(FetchMode fetchMode, [int? forPageNumber]) {
    if (forPageNumber != null && (forPageNumber < 0 || forPageNumber >= totalPages)) {
      forPageNumber = null;
    }
    switch (fetchMode) {
      case FetchMode.clear:
        {
          content.clear();
          pageNumber = -1;
          totalElements = 0;
          totalPages = 0;
          _nextPageStep = 1;
          break;
        }
      case FetchMode.refreshPage:
        {
          if (forPageNumber != null) {
            final offset = forPageNumber * pageSize;
            final limit = offset + pageSize;
            if (limit < content.length) {
              content.removeRange(limit, content.length);
            }
            pageNumber = forPageNumber;
          }
          _nextPageStep = 0;
          break;
        }
      case FetchMode.nextPage:
        {
          _nextPageStep = 1;
          break;
        }
    }
  }

  bool indexIsLastPageItem(int index) {
    return (index + 1) % pageSize == 0;
  }

  int pageNumberOfElement(T element) {
    final index = content.indexOf(element);
    return pageNumberOfIndex(index);
  }

  int pageNumberOfIndex(int index) {
    return index ~/ pageSize;
  }
}
