import 'domain/wallet.dart';

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
}
