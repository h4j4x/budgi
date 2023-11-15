import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../util/datetime.dart';

class DateInputWidget extends StatelessWidget {
  final DateTime? minValue;
  final DateTime value;
  final DateTime? maxValue;
  final String? label;
  final String pattern;
  final Function(DateTime) onChange;

  const DateInputWidget({
    super.key,
    this.minValue,
    required this.value,
    this.maxValue,
    this.label,
    this.pattern = 'dd/MM/yyyy',
    required this.onChange,
  });

  String text(BuildContext context) {
    String prefix = '';
    if (label != null) {
      prefix = '$label: ';
    }
    return L10n.of(context).prefixWithDate(prefix, value);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final now = DateTime.now();
        final selected = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: minValue ?? DateTime(now.year - 1),
          lastDate: maxValue ?? DateTime(now.year + 1),
        );
        if (selected != null) {
          onChange(selected.atStartOfDay());
        }
      },
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.calendar_today),
          ),
          Expanded(
            child: Center(
              child: Text(text(context)),
            ),
          ),
        ],
      ),
    );
  }
}
