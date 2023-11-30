import 'dart:async';

import 'package:flutter/material.dart';

import '../model/domain/user.dart';
import '../model/error/validation.dart';

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

  AppUser fetchUser<T>({required T errorIfMissing}) {
    final appUser = user();
    if (appUser != null) {
      return appUser;
    }
    throw ValidationError<T>({
      'user': errorIfMissing,
    });
  }
}
