import 'package:budgi/model/table.dart';
import 'package:budgi/util/collection.dart';
import 'package:test/test.dart';

void main() {
  void testWidthsPercents(List<double> widthsDefinitions, List<double> expectedWidths, double totalWidth) {
    final columns = widthsDefinitions.mapIndexed((index, width) {
      return TableColumn(label: index.toString(), widthPercent: width > 0 ? width / 100 : null);
    }).toList();
    final widths = calculateTableWidths(columns, totalWidth);
    expect(widths, equals(expectedWidths));
  }

  test('calculateWidths() calculate widths according to given total width', () {
    testWidthsPercents(<double>[0, 20, 20, 20, 0], <double>[20, 20, 20, 20, 20], 100);
    testWidthsPercents(<double>[0, 0, 0, 20, 0], <double>[20, 20, 20, 20, 20], 100);
    testWidthsPercents(<double>[0, 20, 20, 50], <double>[10, 20, 20, 50], 100);
    testWidthsPercents(<double>[0, 0], <double>[50, 50], 100);
    testWidthsPercents(<double>[40, 0], <double>[40, 60], 100);

    testWidthsPercents(<double>[0, 20, 20, 20, 0], <double>[40, 40, 40, 40, 40], 200);
    testWidthsPercents(<double>[0, 0, 0, 20, 0], <double>[40, 40, 40, 40, 40], 200);
    testWidthsPercents(<double>[0, 20, 20, 50], <double>[20, 40, 40, 100], 200);
    testWidthsPercents(<double>[0, 0], <double>[100, 100], 200);
    testWidthsPercents(<double>[40, 0], <double>[80, 120], 200);

    final columns = <TableColumn>[
      TableColumn(label: '0', fixedWidth: 10),
      TableColumn(label: '1', fixedWidth: 10),
      TableColumn(label: '2', widthPercent: 50),
      TableColumn(label: '3'),
    ];
    var widths = calculateTableWidths(columns, 200);
    expect(widths, equals(<double>[10, 10, 100, 80]));

    columns.add(TableColumn(label: '4'));
    widths = calculateTableWidths(columns, 200);
    expect(widths, equals(<double>[10, 10, 100, 40, 40]));
  });
}
