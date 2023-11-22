import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../app/info.dart';
import '../../app/router.dart';
import '../../di.dart';
import '../../error/validation.dart';
import '../../l10n/l10n.dart';
import '../../model/wallet.dart';
import '../../model/wallet_error.dart';
import '../../service/impl/wallet_validator.dart';
import '../../service/wallet.dart';
import '../common/form_toolbar.dart';

class WalletEdit extends StatefulWidget {
  final Wallet? value;

  const WalletEdit({
    super.key,
    this.value,
  });

  @override
  State<StatefulWidget> createState() {
    return _WalletEditState();
  }
}

class _WalletEditState extends State<WalletEdit> {
  final nameController = TextEditingController();
  final nameFocus = FocusNode();
  final errors = <String, WalletError>{};

  bool saving = false;
  WalletType? walletType;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      nameController.text = widget.value!.name;
      walletType = widget.value!.walletType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      walletTypeField(),
      nameField(),
      const SizedBox(height: 24),
      FormToolbar(enabled: !saving, onSave: onSave),
    ];
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.separated(
          itemBuilder: (_, index) {
            return items[index];
          },
          separatorBuilder: (_, __) {
            return const Divider(color: Colors.transparent);
          },
          itemCount: items.length,
        ),
      ),
    );
  }

  Widget walletTypeField() {
    return DropdownButtonFormField<WalletType>(
      items: WalletType.values.map(walletTypeOption).toList(),
      value: walletType,
      decoration: InputDecoration(
        icon: AppIcon.wallet,
        hintText: L10n.of(context).walletTypeHint,
        errorText: errors[WalletValidator.walletType]?.l10n(context),
      ),
      isExpanded: true,
      onChanged: widget.value == null
          ? (selectedWalletType) {
              if (selectedWalletType != null) {
                setState(() {
                  errors.remove(WalletValidator.walletType);
                  walletType = selectedWalletType;
                });
                nameFocus.requestFocus();
              }
            }
          : null,
    );
  }

  DropdownMenuItem<WalletType> walletTypeOption(WalletType value) {
    return DropdownMenuItem<WalletType>(
      value: value,
      enabled: value != walletType,
      child: Text(value.l10n(context)),
    );
  }

  Widget nameField() {
    final l10n = L10n.of(context);
    return TextField(
      controller: nameController,
      textInputAction: TextInputAction.go,
      enabled: !saving,
      focusNode: nameFocus,
      maxLength: AppInfo.textFieldMaxLength,
      decoration: InputDecoration(
        labelText: l10n.walletName,
        hintText: l10n.walletNameHint,
        errorText: errors[WalletValidator.name]?.l10n(context),
      ),
      onChanged: (_) {
        setState(() {
          errors.remove(WalletValidator.name);
        });
      },
      onSubmitted: (_) {
        onSave();
      },
    );
  }

  void onSave() async {
    if (saving) {
      return;
    }

    if (walletType == null) {
      setState(() {
        errors[WalletValidator.walletType] = WalletError.invalidWalletType;
      });
      return;
    }

    setState(() {
      errors.clear();
      saving = true;
    });
    try {
      await DI().get<WalletService>().saveWallet(
            code: widget.value?.code,
            walletType: walletType!,
            name: nameController.text,
          );
      if (mounted) {
        context.pop();
      }
    } on ValidationError<WalletError> catch (e) {
      errors.addAll(e.errors);
    } finally {
      setState(() {
        saving = false;
      });
    }
  }
}
