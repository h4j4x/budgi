import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'theme.dart';

// https://fontawesome.com/search?o=r&m=free
class AppIcon {
  AppIcon._();

  static Widget get about {
    return const _Icon(FontAwesomeIcons.info);
  }

  static Widget get add {
    return const _Icon(FontAwesomeIcons.plus);
  }

  static Widget get category {
    return const _Icon(FontAwesomeIcons.tags);
  }

  static Widget get categoryAmount {
    return const _Icon(FontAwesomeIcons.userTag);
  }

  static Widget get calendar {
    return const _Icon(FontAwesomeIcons.calendar);
  }

  static Widget get clear {
    return const _Icon(FontAwesomeIcons.ban);
  }

  static Widget delete(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return _Icon(FontAwesomeIcons.trash, color: color);
  }

  static Widget get filter {
    return const _Icon(FontAwesomeIcons.filter);
  }

  static Widget get home {
    return const _Icon(FontAwesomeIcons.house);
  }

  static Widget get github {
    return const _Icon(FontAwesomeIcons.github);
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

  static Widget get menu {
    return const Icon(Icons.menu);
  }

  static Widget get reload {
    return const _Icon(FontAwesomeIcons.rotate);
  }

  static Widget get signIn {
    return const _Icon(FontAwesomeIcons.arrowRightToBracket);
  }

  static Widget signOut(BuildContext context) {
    final color = Theme.of(context).colorScheme.warning;
    return _Icon(FontAwesomeIcons.arrowRightFromBracket, color: color);
  }

  static Widget get sortAsc {
    return const _Icon(FontAwesomeIcons.arrowUpShortWide);
  }

  static Widget get sortDesc {
    return const _Icon(FontAwesomeIcons.arrowDownWideShort);
  }

  static Widget get status {
    return const _Icon(FontAwesomeIcons.star);
  }

  static Widget get transaction {
    return const _Icon(FontAwesomeIcons.moneyBillTrendUp);
  }

  static Widget transactionCompleted(BuildContext context) {
    final color = Theme.of(context).colorScheme.success;
    return _Icon(FontAwesomeIcons.checkDouble, color: color);
  }

  static Widget transactionExpense(BuildContext context) {
    final color = Theme.of(context).colorScheme.warning;
    return _Icon(FontAwesomeIcons.moneyCheck, color: color);
  }

  static Widget transactionExpenseTransfer(BuildContext context) {
    final color = Theme.of(context).colorScheme.warning;
    return _Icon(FontAwesomeIcons.moneyBillTransfer, color: color);
  }

  static Widget transactionPending(BuildContext context) {
    final color = Theme.of(context).colorScheme.warning;
    return _Icon(FontAwesomeIcons.barsProgress, color: color);
  }

  static Widget transactionTransfer(BuildContext context) {
    final color = Theme.of(context).colorScheme.warning;
    return _Icon(FontAwesomeIcons.moneyBillTransfer, color: color);
  }

  static Widget transactionIncome(BuildContext context) {
    final color = Theme.of(context).colorScheme.success;
    return _Icon(FontAwesomeIcons.moneyCheckDollar, color: color);
  }

  static Widget transactionIncomeTransfer(BuildContext context) {
    final color = Theme.of(context).colorScheme.success;
    return _Icon(FontAwesomeIcons.moneyBillTransfer, color: color);
  }

  static Widget get user {
    return const _Icon(FontAwesomeIcons.user);
  }

  static Widget get wallet {
    return const _Icon(FontAwesomeIcons.wallet);
  }

  static Widget get walletCash {
    return const _Icon(FontAwesomeIcons.sackDollar);
  }

  static Widget get walletCreditCard {
    return const _Icon(FontAwesomeIcons.creditCard);
  }

  static Widget get walletDebitCard {
    return const _Icon(FontAwesomeIcons.solidCreditCard);
  }

  static Widget tiny(Widget icon) {
    if (icon is FaIcon) {
      return FaIcon(
        icon.icon,
        color: icon.color,
        size: 8,
      );
    }
    if (icon is Icon) {
      return Icon(
        icon.icon,
        color: icon.color,
        size: 8,
      );
    }
    if (icon is _Icon) {
      return _Icon(
        icon.icon,
        color: icon.color,
        size: 8,
      );
    }
    return icon;
  }
}

class _Icon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;

  const _Icon(
    this.icon, {
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return FaIcon(
      icon,
      color: color,
      size: size ?? 16,
    );
  }
}
