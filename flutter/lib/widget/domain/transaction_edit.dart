import 'package:flutter/material.dart';

import '../../app/config.dart';
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
import '../../service/spring/http_client.dart';
import '../../service/storage.dart';
import '../../service/transaction.dart';
import '../../service/wallet.dart';
import '../../util/ui.dart';
import '../common/form_toolbar.dart';
import 'category_select.dart';
import 'transaction_status_select.dart';
import 'transaction_type_select.dart';
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

const _lastTransactionTypeKey = 'last_transaction_type_key';
const _lastCategoryKey = 'last_category_key';
const _lastWalletKey = 'last_wallet_key';

class _TransactionEditState extends State<TransactionEdit> {
  final amountController = TextEditingController();
  final amountFocus = FocusNode();
  final deferredMonthsController = TextEditingController(text: '1');
  final descriptionController = TextEditingController();
  final descriptionFocus = FocusNode();
  final errors = <String, TransactionError>{};

  bool canEdit = false;
  bool saving = false;
  List<Category>? categories;
  List<Wallet>? wallets;

  TransactionType? transactionType;
  TransactionStatus transactionStatus = TransactionStatus.completed;
  Category? category;
  Wallet? wallet;
  Wallet? walletTarget;

  bool get isWalletTransfer {
    return transactionType == TransactionType.walletTransfer;
  }

  bool get isNotWalletTransfer {
    return transactionType != TransactionType.walletTransfer;
  }

  bool get isCreditCardExpense {
    return isNotWalletTransfer &&
        wallet?.walletType == WalletType.creditCard &&
        transactionType == TransactionType.expense;
  }

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      category = widget.value!.category;
      wallet = widget.value!.wallet;
      transactionType = widget.value!.transactionType;
      transactionStatus = widget.value!.transactionStatus;
      amountController.text = widget.value!.amount.toStringAsFixed(2).toString();
      descriptionController.text = widget.value!.description;
      canEdit = Period.currentMonth.contains(widget.value!.dateTime);
    } else {
      canEdit = true;
    }
    Future.delayed(Duration.zero, () {
      loadCategories();
      loadWallets();
      loadLastTransactionType();
    });
  }

  void loadCategories() async {
    final lastCategory = await DI().get<StorageService>().readString(_lastCategoryKey);
    final list = await DI().get<CategoryService>().listCategories(
          pageSize: 1000, // TODO: select with filter & pagination
        );
    if (category == null && lastCategory != null) {
      category = list.content.where((item) => item.code == lastCategory).firstOrNull;
    }
    setState(() {
      categories = list.content;
    });
  }

  void loadWallets() async {
    final lastWallet = await DI().get<StorageService>().readString(_lastWalletKey);
    final list = await DI().get<WalletService>().listWallets();
    if (wallet == null && lastWallet != null) {
      wallet = list.content.where((item) => item.code == lastWallet).firstOrNull;
    }
    setState(() {
      wallets = list.content;
    });
  }

  void loadLastTransactionType() async {
    final lastTransactionType = await DI().get<StorageService>().readString(_lastTransactionTypeKey);
    if (transactionType == null && lastTransactionType != null) {
      setState(() {
        transactionType = TransactionType.tryParse(lastTransactionType);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      transactionTypeField(),
      transactionStatusField(),
      categoryField(),
      walletField(),
      if (isWalletTransfer) walletTargetField(),
      amountField(),
      if (isCreditCardExpense) deferredMonthsField(),
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
    return TransactionTypeSelect(
      enabled: canEdit,
      allowClear: false,
      onChanged: (value) {
        setState(() {
          errors.remove(TransactionValidator.transactionType);
          transactionType = value;
        });
        updateTransactionStatus();
        amountFocus.requestFocus();
        if (value != null) {
          DI().get<StorageService>().writeString(_lastTransactionTypeKey, value.name);
        }
      },
      list: TransactionType.values.where((value) {
        return value != TransactionType.incomeTransfer && value != TransactionType.expenseTransfer;
      }).toList(),
      value: transactionType,
      hintText: L10n.of(context).transactionTypeHint,
      errorText: errors[TransactionValidator.description]?.l10n(context),
    );
  }

  Widget transactionStatusField() {
    return TransactionStatusSelect(
      enabled: false,
      allowClear: false,
      onChanged: (value) {
        setState(() {
          transactionStatus = value!;
        });
        amountFocus.requestFocus();
      },
      value: transactionStatus,
    );
  }

  Widget categoryField() {
    return CategorySelect(
      list: categories,
      value: category,
      allowClear: false,
      enabled: widget.value == null,
      onChanged: (value) {
        setState(() {
          errors.remove(TransactionValidator.category);
          category = value;
        });
        if (value != null) {
          DI().get<StorageService>().writeString(_lastCategoryKey, value.code);
        }
      },
      hintText: L10n.of(context).budgetAmountCategoryHint,
      errorText: errors[TransactionValidator.category]?.l10n(context),
    );
  }

  Widget walletField() {
    return WalletSelect(
      list: (wallets ?? []).where((item) => item != walletTarget).toList(),
      value: wallet,
      allowClear: false,
      onChanged: (value) {
        setState(() {
          errors.remove(TransactionValidator.wallet);
          wallet = value;
        });
        updateTransactionStatus();
        if (value != null) {
          DI().get<StorageService>().writeString(_lastWalletKey, value.code);
        }
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
      allowClear: false,
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

  void updateTransactionStatus() {
    transactionStatus = TransactionStatus.completed;
    if (isCreditCardExpense) {
      transactionStatus = TransactionStatus.pending;
    }
    setState(() {});
  }

  Widget amountField() {
    final l10n = L10n.of(context);
    return TextField(
      controller: amountController,
      textInputAction: TextInputAction.next,
      enabled: !saving,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      focusNode: amountFocus,
      textAlign: TextAlign.end,
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

  Widget deferredMonthsField() {
    final l10n = L10n.of(context);
    return TextField(
      controller: deferredMonthsController,
      textInputAction: TextInputAction.next,
      enabled: canEdit && !saving,
      keyboardType: const TextInputType.numberWithOptions(),
      textAlign: TextAlign.end,
      decoration: InputDecoration(
        labelText: l10n.transactionDeferredMonths,
        hintText: l10n.transactionDeferredMonthsHint,
      ),
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
      if (descriptionController.text.trim().isNotEmpty) {
        description = descriptionController.text.trim();
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
        final deferredMonths = int.tryParse(deferredMonthsController.text);
        await DI().get<TransactionService>().saveTransaction(
              code: widget.value?.code,
              category: category!,
              wallet: wallet!,
              transactionType: transactionType!,
              transactionStatus: transactionStatus,
              description: description,
              amount: amount,
              deferredMonths: deferredMonths,
            );
      }
      if (mounted) {
        context.pop();
      }
    } on ValidationError<TransactionError> catch (e) {
      errors.addAll(e.errors);
    } on HttpError catch (e) {
      if (mounted) {
        context.showError(e.l10n(context));
      }
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
