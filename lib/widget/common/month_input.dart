import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../../app/icon.dart';
import '../../model/period.dart';
import '../../util/datetime.dart';

class MonthInputWidget extends StatefulWidget {
  final Period period;
  final Function(Period)? onChange;

  const MonthInputWidget({
    super.key,
    required this.period,
    this.onChange,
  });

  @override
  State<MonthInputWidget> createState() => _MonthInputWidgetState();
}

class _MonthInputWidgetState extends State<MonthInputWidget> {
  final controller = TextEditingController();

  late Period period;

  @override
  void initState() {
    super.initState();
    period = widget.period;
    Future.delayed(Duration.zero, updateController);
  }

  void updateController() {
    controller.text = formatDateTimePeriod(
      context,
      period: period,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onChange != null ? onSelect : null,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            icon: AppIcon.calendar,
          ),
          readOnly: true,
          enabled: false,
        ),
      ),
    );
  }

  void onSelect() async {
    final dateTime = await showMonthYearPicker(
      context: context,
      initialDate: DateTime(period.from.year, period.from.month),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (dateTime != null) {
      setState(() {
        period = Period.monthFromDateTime(dateTime);
        updateController();
      });
      widget.onChange!(period);
    }
  }
}
