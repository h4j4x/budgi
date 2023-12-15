import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../model/domain/transaction.dart';
import '../common/select_field.dart';

class TransactionStatusSelect extends StatelessWidget {
  final TransactionStatus? value;
  final Function(TransactionStatus?) onChanged;
  final String? hintText;
  final String? errorText;
  final bool allowClear;
  final bool enabled;

  const TransactionStatusSelect({
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
    return SelectField<TransactionStatus>(
      items: TransactionStatus.values,
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
      icon: AppIcon.status,
      iconBuilder: (context, value) {
        return value.icon(context);
      },
      hintText: hintText,
      errorText: errorText,
    );
  }
}
