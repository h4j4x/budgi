class DataPage<T> {
  List<T> content;
  int pageNumber;
  int pageSize;
  int totalElements;

  DataPage({
    required this.content,
    this.pageNumber = 0,
    int? pageSize,
    int? totalElements,
  })  : pageSize = pageSize ?? content.length,
        totalElements = totalElements ?? content.length;

  static DataPage<T> empty<T>() {
    return DataPage<T>(content: <T>[]);
  }
}
