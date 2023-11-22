import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

// https://github.com/microsoft/fluentui-system-icons/blob/main/icons_regular.md
// https://fluenticons.co/
class AppIcon {
  AppIcon._();

  static Icon get about {
    return const Icon(FluentIcons.info_24_regular);
  }

  static Icon get add {
    return const Icon(FluentIcons.add_24_regular);
  }

  static Icon get category {
    return const Icon(FluentIcons.apps_24_regular);
  }

  static Icon get categoryAmount {
    return const Icon(FluentIcons.apps_add_in_24_regular);
  }

  static Icon get calendar {
    return const Icon(FluentIcons.calendar_24_regular);
  }

  static Icon get delete {
    return const Icon(FluentIcons.delete_24_regular);
  }

  static Icon get expenseTransaction {
    return const Icon(FluentIcons.washer_24_regular);
  }

  static Icon get expenseTransfer {
    return const Icon(FluentIcons.building_bank_toolbox_24_regular);
  }

  static Icon get home {
    return const Icon(FluentIcons.board_24_regular);
  }

  static Icon get incomeTransaction {
    return const Icon(FluentIcons.money_24_regular);
  }

  static Icon get incomeTransfer {
    return const Icon(FluentIcons.building_bank_24_regular);
  }

  static Icon get loading {
    return const Icon(FluentIcons.timer_24_regular);
  }

  static Icon get reload {
    return const Icon(FluentIcons.arrow_sync_24_regular);
  }

  static Icon get transaction {
    return const Icon(FluentIcons.payment_24_regular);
  }

  static Icon get wallet {
    return const Icon(FluentIcons.wallet_24_regular);
  }
}
