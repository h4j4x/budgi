import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

// https://github.com/microsoft/fluentui-system-icons/blob/main/icons_regular.md
class AppIcon {
  static Icon get home {
    return const Icon(FluentIcons.home_24_regular);
  }

  static Icon get budgetCategory {
    return const Icon(FluentIcons.album_24_regular);
  }

  static Icon get budgetCategoryAmount {
    return const Icon(FluentIcons.album_add_24_regular);
  }
}