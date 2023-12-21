import 'package:flutter/material.dart';

abstract class AppUser {
  String get id;

  String? get avatarUrl;

  String? get email;

  String get name;

  String get username;

  Widget icon({double? size, Color? color});

  String get usernameOrEmail;
}
