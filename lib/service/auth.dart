import 'dart:async';

import 'package:flutter/material.dart';

import '../model/domain/user.dart';

abstract class AuthService {
  Future<bool> signIn(
    BuildContext context, {
    required String email,
    required String password,
  });

  Future<bool> signInWithGithub(BuildContext context);

  Stream<bool> authenticatedStream();

  AppUser? user();

  Future<void> signOut();
}
