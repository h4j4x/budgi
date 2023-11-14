import 'package:flutter/material.dart';

import '../../util/datetime.dart';

class DateInputWidget extends StatelessWidget {
  final DateTime value;
  final String? label;
  final String pattern;
  final Function(DateTime) onChange;

  const DateInputWidget({
    super.key,
    required this.value,
    this.label,
    this.pattern = 'dd/MM/yyyy',
    required this.onChange,
  });

  String get text {
    String prefix = '';
    if (label != null) {
      prefix = '$label: ';
    }
    return '$prefix ${value.toStringFormatted(pattern)}';
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final now = DateTime.now();
        final selected = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 1),
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
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
