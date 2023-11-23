import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../app/info.dart';
import '../../app/router.dart';
import '../../di.dart';
import '../../error/validation.dart';
import '../../l10n/l10n.dart';
import '../../model/category.dart';
import '../../model/period.dart';
import '../../model/transaction.dart';
import '../../model/transaction_error.dart';
import '../../model/wallet.dart';
import '../../service/category.dart';
import '../../service/impl/category_validator.dart';
import '../../service/impl/transaction_validator.dart';
import '../../service/transaction.dart';
import '../../service/wallet.dart';
import '../common/form_toolbar.dart';

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
  Category? category;
  List<Wallet>? wallets;
  Wallet? wallet;
  TransactionType? transactionType;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      category = widget.value!.category;
      wallet = widget.value!.wallet;
      transactionType = widget.value!.transactionType;
      amountController.text =
          widget.value!.amount.toStringAsFixed(2).toString();
      descriptionController.text = widget.value!.description;
      canEdit = Period.currentMonth.contains(widget.value!.dateTime);
    } else {
      canEdit = true;
    }
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
      categoryField(),
      walletField(),
      transactionTypeField(),
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

  Widget categoryField() {
    return DropdownButtonFormField<Category>(
      items: (categories ?? []).map(categoryOption).toList(),
      value: category,
      decoration: InputDecoration(
        icon: categories == null ? AppIcon.loading : AppIcon.category,
        hintText: L10n.of(context).transactionCategoryHint,
        errorText: errors[CategoryAmountValidator.category]?.l10n(context),
      ),
      isExpanded: true,
      onChanged: canEdit
          ? (selectedCategory) {
              if (selectedCategory != null) {
                setState(() {
                  errors.remove(TransactionValidator.category);
                  category = selectedCategory;
                });
              }
            }
          : null,
    );
  }

  DropdownMenuItem<Category> categoryOption(Category value) {
    return DropdownMenuItem<Category>(
      value: value,
      enabled: value != category,
      child: Text(value.name),
    );
  }

  Widget walletField() {
    return DropdownButtonFormField<Wallet>(
      items: (wallets ?? []).map(walletOption).toList(),
      value: wallet,
      decoration: InputDecoration(
        icon: wallets == null ? AppIcon.loading : AppIcon.wallet,
        hintText: L10n.of(context).transactionWalletHint,
        errorText: errors[CategoryAmountValidator.category]?.l10n(context),
      ),
      isExpanded: true,
      onChanged: canEdit
          ? (selectedWallet) {
              if (selectedWallet != null) {
                setState(() {
                  errors.remove(TransactionValidator.wallet);
                  wallet = selectedWallet;
                });
              }
            }
          : null,
    );
  }

  DropdownMenuItem<Wallet> walletOption(Wallet value) {
    return DropdownMenuItem<Wallet>(
      value: value,
      enabled: value != wallet,
      child: Text(value.name),
    );
  }

  Widget transactionTypeField() {
    return DropdownButtonFormField<TransactionType>(
      items: TransactionType.values.map((value) {
        return transactionTypeOption(value);
      }).toList(),
      selectedItemBuilder: (context) {
        return TransactionType.values.map((value) {
          return transactionTypeOption(value, false);
        }).toList();
      },
      value: transactionType,
      decoration: InputDecoration(
        icon: transactionType == null
            ? AppIcon.transaction
            : transactionType!.icon(context),
        hintText: L10n.of(context).transactionTypeHint,
        errorText: errors[TransactionValidator.description]?.l10n(context),
      ),
      isExpanded: true,
      onChanged: canEdit
          ? (selectedTransactionType) {
              if (selectedTransactionType != null) {
                setState(() {
                  errors.remove(TransactionValidator.transactionType);
                  transactionType = selectedTransactionType;
                });
                amountFocus.requestFocus();
              }
            }
          : null,
    );
  }

  DropdownMenuItem<TransactionType> transactionTypeOption(
    TransactionType value, [
    bool withIcon = true,
  ]) {
    Widget child = Text(value.l10n(context));
    if (withIcon) {
      child = Row(
        children: [
          value.icon(context),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: child,
          ),
        ],
      );
    }
    return DropdownMenuItem<TransactionType>(
      value: value,
      enabled: value != transactionType,
      child: child,
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
        errorText: errors[CategoryAmountValidator.amount]?.l10n(context),
      ),
      onChanged: (_) {
        setState(() {
          errors.remove(CategoryAmountValidator.amount);
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
      maxLength: AppInfo.textFieldMaxLength,
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

    if (category == null) {
      setState(() {
        errors[TransactionValidator.category] =
            TransactionError.invalidCategory;
      });
      return;
    }

    if (wallet == null) {
      setState(() {
        errors[TransactionValidator.wallet] = TransactionError.invalidWallet;
      });
      return;
    }

    if (transactionType == null) {
      setState(() {
        errors[TransactionValidator.transactionType] =
            TransactionError.invalidTransactionType;
      });
      return;
    }

    setState(() {
      errors.clear();
      saving = true;
    });
    try {
      final amount = double.tryParse(amountController.text) ?? -1;
      await DI().get<TransactionService>().saveTransaction(
            code: widget.value?.code,
            category: category!,
            wallet: wallet!,
            transactionType: transactionType!,
            description: descriptionController.text,
            amount: amount,
          );
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
}
