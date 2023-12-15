import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../model/domain/transaction.dart';
import '../common/select_field.dart';

class TransactionTypeSelect extends StatelessWidget {
  final TransactionType? value;
  final Function(TransactionType?) onChanged;
  final String? hintText;
  final String? errorText;
  final bool allowClear;
  final bool enabled;

  const TransactionTypeSelect({
    super.key,
    this.value,
    required this.onChanged,
    this.hintText,
    this.errorText,
    this.allowClear = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SelectField<TransactionType>(
      items: TransactionType.values,
      itemBuilder: (context, value) {
        return Text(value.l10n(context));
      },
      onClear: enabled && allowClear
          ? () {
              onChanged(null);
            }
          : null,
      onChanged: enabled
          ? (value) {
              onChanged(value);
            }
          : null,
      selectedValue: value,
      icon: AppIcon.transaction,
      iconBuilder: (context, value) {
        return value.icon(context);
      },
      hintText: hintText,
      errorText: errorText,
    );
  }
}
