import 'package:flutter/material.dart';

import '../../model/callback.dart';
import '../../model/sort.dart';
import 'select_field.dart';

class SortField extends StatelessWidget {
  final Sort value;
  final TypedCallback<Sort>? onChanged;

  const SortField({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SelectField<Sort>(
      selectedValue: value,
      items: Sort.values,
      itemBuilder: (context, item) {
        return Text(item.l10n(context));
      },
      icon: value.icon(),
      iconBuilder: (_, item) {
        return item.icon();
      },
      onChanged: onChanged,
    );
  }
}
