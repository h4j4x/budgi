import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class AppInfo {
  static int get textFieldMaxLength {
    return 200;
  }

  Future<String> version();
}

// https://pub.dev/packages/package_info_plus
class PackageAppInfo implements AppInfo {
  PackageInfo? packageInfo;

  PackageAppInfo() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Future<String> version() async {
    packageInfo ??= await PackageInfo.fromPlatform();
    return packageInfo!.version;
  }
}
