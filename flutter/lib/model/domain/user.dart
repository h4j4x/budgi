import 'package:flutter/material.dart';

abstract class AppUser {
  String get id;

  String? get avatarUrl;

  String? get email;

  String get name;

  String get username;

  Widget get icon;

  String get usernameOrEmail;
}
