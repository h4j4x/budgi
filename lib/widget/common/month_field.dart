import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../../app/icon.dart';
import '../../model/callback.dart';
import '../../model/period.dart';
import '../../util/datetime.dart';

class MonthFieldWidget extends StatefulWidget {
  final Period period;
  final TypedCallback<Period>? onChanged;

  const MonthFieldWidget({
    super.key,
    required this.period,
    this.onChanged,
  });

  @override
  State<MonthFieldWidget> createState() => _MonthFieldWidgetState();
}

class _MonthFieldWidgetState extends State<MonthFieldWidget> {
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
      onTap: widget.onChanged != null ? onSelect : null,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: AbsorbPointer(
          absorbing: true,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              icon: AppIcon.calendar,
            ),
            readOnly: true,
            enabled: widget.onChanged != null,
          ),
        ),
      ),
    );
  }

  // https://pub.dev/packages/month_year_picker
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
      widget.onChanged!(period);
    }
  }
}
