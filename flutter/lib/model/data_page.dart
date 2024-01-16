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

  int get pageIndexStart {
    final index = pageNumber * pageSize;
    return max(index, 0);
  }

  int get pageIndexEnd {
    final index = pageIndexStart + pageSize;
    return min(index, content.length);
  }

  int get pageLength {
    return pageIndexEnd - pageIndexStart;
  }

  List<T> get pageContent {
    return content.sublist(pageIndexStart, pageIndexEnd);
  }

  void add(DataPage<T> dataPage) {
    if (pageNumber < dataPage.pageNumber) {
      content.addAll(dataPage.content);
      pageNumber = dataPage.pageNumber;
    } else {
      final pageIndexStart = dataPage.pageNumber * dataPage.pageSize;
      final pageIndexEnd = min(pageIndexStart + dataPage.pageSize, content.length);
      content.replaceRange(pageIndexStart, pageIndexEnd, dataPage.content);
    }
    pageSize = dataPage.pageSize;
    totalElements = dataPage.totalElements;
    totalPages = dataPage.totalPages;
  }

  T operator [](int index) {
    return content[index];
  }

  static DataPage<T> empty<T>() {
    return DataPage<T>(content: <T>[], pageSize: 10);
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
            final pageIndexStart = max(forPageNumber * pageSize, 0);
            final pageIndexEnd = pageIndexStart + pageSize;
            if (pageIndexEnd < content.length) {
              content.removeRange(pageIndexEnd, content.length);
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
