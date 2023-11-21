import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

// https://github.com/microsoft/fluentui-system-icons/blob/main/icons_regular.md
// https://fluenticons.co/
class AppIcon {
  static Icon get about {
    return const Icon(FluentIcons.info_24_regular);
  }

  static Icon get add {
    return const Icon(FluentIcons.add_24_regular);
  }

  static Icon get budgetCategory {
    return const Icon(FluentIcons.apps_24_regular);
  }

  static Icon get budgetCategoryAmount {
    return const Icon(FluentIcons.apps_add_in_24_regular);
  }

  static Icon get calendar {
    return const Icon(FluentIcons.calendar_24_regular);
  }

  static Icon get delete {
    return const Icon(FluentIcons.delete_24_regular);
  }

  static Icon get home {
    return const Icon(FluentIcons.board_24_regular);
  }

  static Icon get reload {
    return const Icon(FluentIcons.arrow_sync_24_regular);
  }

  static Icon get wallet {
    return const Icon(FluentIcons.wallet_24_regular);
  }
}