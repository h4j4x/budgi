import 'dart:async';

import 'package:flutter/material.dart';

import '../model/user.dart';

abstract class AuthService {
  Future<bool> signInWithGithub(BuildContext context);

  Stream<bool> authenticatedStream();

  AppUser? user();
}
