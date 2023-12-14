import 'package:flutter/material.dart';

import '../../app/config.dart';
import '../../app/icon.dart';
import '../../app/router.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/category.dart';
import '../../model/domain/transaction.dart';
import '../../model/domain/wallet.dart';
import '../../model/error/transaction.dart';
import '../../model/error/validation.dart';
import '../../model/period.dart';
import '../../service/category.dart';
import '../../service/impl/transaction_validator.dart';
import '../../service/transaction.dart';
import '../../service/wallet.dart';
import '../common/form_toolbar.dart';
import '../common/select_field.dart';
import 'category_select.dart';
import 'wallet_select.dart';

class TransactionEdit extends StatefulWidget {
  final Transaction? value;

  const TransactionEdit({
    super.key,
    this.value,
  });

  @override
  State<StatefulWidget> createState() {
    return _TransactionEditState();
  }
}

class _TransactionEditState extends State<TransactionEdit> {
  final amountController = TextEditingController();
  final amountFocus = FocusNode();
  final descriptionController = TextEditingController();
  final descriptionFocus = FocusNode();
  final errors = <String, TransactionError>{};

  bool canEdit = false;
  bool saving = false;
  List<Category>? categories;
  List<Wallet>? wallets;

  TransactionType? transactionType;
  Category? category;
  Wallet? wallet;
  Wallet? walletTarget;

  bool get isWalletTransfer {
    return transactionType == TransactionType.walletTransfer;
  }

  bool get isNotWalletTransfer {
    return transactionType != TransactionType.walletTransfer;
  }

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      category = widget.value!.category;
      wallet = widget.value!.wallet;
      transactionType = widget.value!.transactionType;
      amountController.text = widget.value!.amount.toStringAsFixed(2).toString();
      descriptionController.text = widget.value!.description;
      canEdit = Period.currentMonth.contains(widget.value!.dateTime);
    } else {
      canEdit = true;
      // todo: load last transactionType used
    }
    transactionType ??= TransactionType.expense;
    Future.delayed(Duration.zero, () {
      loadCategories();
      loadWallets();
    });
  }

  void loadCategories() async {
    final list = await DI().get<CategoryService>().listCategories();
    setState(() {
      categories = list;
    });
  }

  void loadWallets() async {
    final list = await DI().get<WalletService>().listWallets();
    setState(() {
      wallets = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      transactionTypeField(),
      categoryField(),
      walletField(),
      if (isWalletTransfer) walletTargetField(),
      amountField(),
      descriptionField(),
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

  Widget transactionTypeField() {
    return SelectField<TransactionType>(
      items: TransactionType.values,
      itemBuilder: (context, value) {
        return Text(value.l10n(context));
      },
      onChanged: canEdit
          ? (value) {
              setState(() {
                errors.remove(TransactionValidator.transactionType);
                transactionType = value;
              });
              amountFocus.requestFocus();
            }
          : null,
      selectedValue: transactionType,
      icon: AppIcon.transaction,
      iconBuilder: (context, value) {
        return value.icon(context);
      },
      hintText: L10n.of(context).transactionTypeHint,
      errorText: errors[TransactionValidator.description]?.l10n(context),
    );
  }

  Widget categoryField() {
    return CategorySelect(
      list: categories,
      value: category,
      enabled: widget.value == null,
      onChanged: (value) {
        setState(() {
          errors.remove(TransactionValidator.category);
          category = value;
        });
      },
      hintText: L10n.of(context).budgetAmountCategoryHint,
      errorText: errors[TransactionValidator.category]?.l10n(context),
    );
  }

  Widget walletField() {
    return WalletSelect(
      list: (wallets ?? []).where((item) => item != walletTarget).toList(),
      value: wallet,
      onChanged: (value) {
        setState(() {
          errors.remove(TransactionValidator.wallet);
          wallet = value;
        });
      },
      hintText:
          isNotWalletTransfer ? L10n.of(context).transactionWalletHint : L10n.of(context).transactionWalletSourceHint,
      errorText: errors[TransactionValidator.wallet]?.l10n(context),
    );
  }

  Widget walletTargetField() {
    return WalletSelect(
      list: (wallets ?? []).where((item) => item != wallet).toList(),
      value: walletTarget,
      onChanged: (value) {
        setState(() {
          errors.remove(TransactionValidator.walletTarget);
          walletTarget = value;
        });
      },
      hintText: L10n.of(context).transactionWalletTargetHint,
      errorText: errors[TransactionValidator.walletTarget]?.l10n(context),
    );
  }

  Widget amountField() {
    final l10n = L10n.of(context);
    return TextField(
      controller: amountController,
      textInputAction: TextInputAction.next,
      enabled: !saving,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      focusNode: amountFocus,
      decoration: InputDecoration(
        labelText: l10n.transactionAmount,
        hintText: l10n.transactionAmountHint,
        errorText: errors[TransactionValidator.amount]?.l10n(context),
      ),
      onChanged: (_) {
        setState(() {
          errors.remove(TransactionValidator.amount);
        });
      },
      onSubmitted: (_) {
        descriptionFocus.requestFocus();
      },
    );
  }

  Widget descriptionField() {
    final l10n = L10n.of(context);
    return TextField(
      controller: descriptionController,
      textInputAction: TextInputAction.go,
      enabled: !saving,
      focusNode: descriptionFocus,
      maxLength: AppConfig.textFieldMaxLength,
      decoration: InputDecoration(
        labelText: l10n.transactionDescription,
        hintText: l10n.transactionDescriptionHint,
        errorText: errors[TransactionValidator.description]?.l10n(context),
      ),
      onChanged: (_) {
        setState(() {
          errors.remove(TransactionValidator.description);
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

    errors.clear();

    if (transactionType == null) {
      errors[TransactionValidator.transactionType] = TransactionError.invalidTransactionType;
    }

    if (category == null) {
      errors[TransactionValidator.category] = TransactionError.invalidCategory;
    }

    if (wallet == null) {
      errors[TransactionValidator.wallet] = TransactionError.invalidWallet;
    }

    if (isWalletTransfer && walletTarget == null) {
      errors[TransactionValidator.walletTarget] = TransactionError.invalidWalletTarget;
    }

    if (errors.isNotEmpty) {
      setState(() {});
      return;
    }

    setState(() {
      saving = true;
    });
    try {
      final amount = double.tryParse(amountController.text) ?? -1;
      String? description;
      if (descriptionController.text.isNotEmpty) {
        description = descriptionController.text;
      }
      if (isWalletTransfer) {
        await DI().get<TransactionService>().saveWalletTransfer(
              category: category!,
              sourceWallet: wallet!,
              targetWallet: walletTarget!,
              sourceDescription: description ?? L10n.of(context).transferTo(walletTarget!.name),
              targetDescription: description ?? L10n.of(context).transferFrom(wallet!.name),
              amount: amount,
            );
      } else {
        await DI().get<TransactionService>().saveTransaction(
              code: widget.value?.code,
              category: category!,
              wallet: wallet!,
              transactionType: transactionType!,
              description: descriptionController.text,
              amount: amount,
            );
      }
      if (mounted) {
        context.pop();
      }
    } on ValidationError<TransactionError> catch (e) {
      errors.addAll(e.errors);
    } finally {
      setState(() {
        saving = false;
      });
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
