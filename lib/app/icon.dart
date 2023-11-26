import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'theme.dart';

// https://fontawesome.com/search?o=r&m=free
class AppIcon {
  AppIcon._();

  static Widget get about {
    return const FaIcon(FontAwesomeIcons.info);
  }

  static Widget get add {
    return const FaIcon(FontAwesomeIcons.plus);
  }

  static Widget get category {
    return const FaIcon(FontAwesomeIcons.tags);
  }

  static Widget get categoryAmount {
    return const FaIcon(FontAwesomeIcons.userTag);
  }

  static Widget get calendar {
    return const FaIcon(FontAwesomeIcons.calendar);
  }

  static Widget delete(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return FaIcon(FontAwesomeIcons.trash, color: color);
  }

  static Widget get home {
    return const FaIcon(FontAwesomeIcons.house);
  }

  static Widget get github {
    return const FaIcon(FontAwesomeIcons.github);
  }

  static Widget get loading {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }

  static Widget get reload {
    return const FaIcon(FontAwesomeIcons.rotate);
  }

  static Widget get sortAsc {
    return const FaIcon(FontAwesomeIcons.arrowUpShortWide);
  }

  static Widget get sortDesc {
    return const FaIcon(FontAwesomeIcons.arrowDownWideShort);
  }

  static Widget get transaction {
    return const FaIcon(FontAwesomeIcons.moneyBillTrendUp);
  }

  static Widget transactionExpense(BuildContext context) {
    final color = Theme.of(context).colorScheme.warning;
    return FaIcon(FontAwesomeIcons.moneyCheck, color: color);
  }

  static Widget transactionExpenseTransfer(BuildContext context) {
    final color = Theme.of(context).colorScheme.warning;
    return FaIcon(FontAwesomeIcons.moneyBillTransfer, color: color);
  }

  static Widget transactionIncome(BuildContext context) {
    final color = Theme.of(context).colorScheme.success;
    return FaIcon(FontAwesomeIcons.moneyCheckDollar, color: color);
  }

  static Widget transactionIncomeTransfer(BuildContext context) {
    final color = Theme.of(context).colorScheme.success;
    return FaIcon(FontAwesomeIcons.moneyBillTransfer, color: color);
  }

  static Widget get user {
    return const FaIcon(FontAwesomeIcons.user);
  }

  static Widget get wallet {
    return const FaIcon(FontAwesomeIcons.wallet);
  }

  static Widget get walletCash {
    return const FaIcon(FontAwesomeIcons.sackDollar);
  }

  static Widget get walletCreditCard {
    return const FaIcon(FontAwesomeIcons.creditCard);
  }

  static Widget get walletDebitCard {
    return const FaIcon(FontAwesomeIcons.solidCreditCard);
  }
}
