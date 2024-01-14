import 'package:budgi/model/data_page.dart';
import 'package:budgi/model/fetch_mode.dart';
import 'package:test/test.dart';

void main() {
  test('.add() puts data on its place', () {
    final page = DataPage.empty<String>();
    final list1 = <String>['a', 'b', 'c', 'd', 'e'];
    page.add(DataPage<String>(content: list1, pageNumber: 0));
    expect(page.length, equals(list1.length));
    expect(page.pageSize, equals(list1.length));
    expect(page.totalElements, equals(list1.length));
    for (var index = 0; index < list1.length; index++) {
      expect(page[index], equals(list1[index]));
    }

    /// Add page
    final list2 = <String>['f', 'g', 'h', 'i', 'j'];
    final contentLength = list1.length + list2.length;
    page.add(DataPage<String>(content: list2, pageNumber: 1, totalElements: contentLength));
    expect(page.length, equals(contentLength));
    expect(page.pageSize, equals(list1.length));
    expect(page.totalElements, equals(contentLength));
    for (var index = 0; index < list1.length; index++) {
      expect(page[index], equals(list1[index]));
    }
    for (var index = list1.length; index < contentLength; index++) {
      expect(page[index], equals(list2[index - list1.length]));
    }

    /// Replace page
    final list3 = <String>['k', 'l', 'm', 'n', 'o'];
    page.add(DataPage<String>(content: list3, pageNumber: 1, totalElements: contentLength));
    expect(page.length, equals(contentLength));
    expect(page.pageSize, equals(list1.length));
    expect(page.totalElements, equals(contentLength));
    for (var index = 0; index < list1.length; index++) {
      expect(page[index], equals(list1[index]));
    }
    for (var index = list1.length; index < contentLength; index++) {
      expect(page[index], equals(list3[index - list1.length]));
    }
  });

  test('.apply() reorder properties', () {
    final page = DataPage.empty<String>();
    final list1 = <String>['a', 'b', 'c', 'd', 'e'];

    /// FetchMode.clear
    page.add(DataPage<String>(content: list1, pageNumber: 0));
    page.apply(FetchMode.clear);
    expect(page.content.isEmpty, isTrue);
    expect(page.nextPageNumber, equals(0));
    expect(page.length, equals(0));
    expect(page.totalElements, equals(0));
    expect(page.pageSize, equals(list1.length));

    /// FetchMode.refreshPage
    page.add(DataPage<String>(content: list1, pageNumber: 0));
    page.apply(FetchMode.refreshPage);
    expect(page.content.isEmpty, isFalse);
    expect(page.nextPageNumber, equals(0));
    expect(page.length, equals(list1.length));
    expect(page.totalElements, equals(list1.length));
    expect(page.pageSize, equals(list1.length));

    /// FetchMode.nextPage
    page.add(DataPage<String>(content: list1, pageNumber: 0));
    page.apply(FetchMode.nextPage);
    expect(page.content.isEmpty, isFalse);
    expect(page.nextPageNumber, equals(1));
    expect(page.length, equals(list1.length));
    expect(page.totalElements, equals(list1.length));
    expect(page.pageSize, equals(list1.length));
  });

  test('.pageNumberOfElement() gets correct page number', () {
    final page = DataPage.empty<String>();
    final lists = <List<String>>[
      <String>['a', 'b', 'c', 'd', 'e'],
      <String>['f', 'g', 'h', 'i', 'j'],
      <String>['k', 'l', 'm', 'n', 'o'],
    ];
    for (var index = 0; index < lists.length; index++) {
      final list = lists[index];
      page.add(DataPage<String>(content: list, pageNumber: index));
      for (var element in list) {
        final pageNumber = page.pageNumberOfElement(element);
        expect(pageNumber, equals(index));
      }
    }
    final list = <String>[lists[0][2], lists[1][4], lists[2][3]];
    for (var index = 0; index < list.length; index++) {
      final pageNumber = page.pageNumberOfElement(list[index]);
      expect(pageNumber, equals(index));
    }
  });
}
