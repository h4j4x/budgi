import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  static Widget get delete {
    return const FaIcon(FontAwesomeIcons.trash);
  }

  static Widget get home {
    return const FaIcon(FontAwesomeIcons.house);
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

  static Widget get transaction {
    return const FaIcon(FontAwesomeIcons.moneyBillTrendUp);
  }

  static Widget get transactionExpense {
    return const FaIcon(FontAwesomeIcons.moneyCheck);
  }

  static Widget get transactionExpenseTransfer {
    return const FaIcon(FontAwesomeIcons.moneyBillTransfer);
  }

  static Widget get transactionIncome {
    return const FaIcon(FontAwesomeIcons.moneyCheckDollar);
  }

  static Widget get transactionIncomeTransfer {
    return const FaIcon(FontAwesomeIcons.moneyBillTransfer);
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
