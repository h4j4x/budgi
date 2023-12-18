import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../model/domain/wallet.dart';
import '../common/select_field.dart';

class WalletSelect extends StatelessWidget {
  final List<Wallet>? list;
  final Wallet? value;
  final Function(Wallet?) onChanged;
  final String? hintText;
  final String? errorText;
  final bool allowClear;
  final bool enabled;

  const WalletSelect({
    super.key,
    required this.list,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.errorText,
    this.allowClear = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SelectField<Wallet>(
      items: list ?? [],
      itemBuilder: (context, value) {
        return Text(value.name);
      },
      onClear: allowClear && enabled
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
      icon: list == null ? AppIcon.loading : AppIcon.wallet,
      iconBuilder: (context, value) {
        return value.walletType.icon();
      },
      hintText: hintText,
      errorText: errorText,
    );
  }
}
