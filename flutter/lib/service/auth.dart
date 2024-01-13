import 'dart:async';

import '../model/domain/user.dart';
import '../model/token.dart';

abstract class AuthService {
  /// @throws SignInError
  Future<bool> signIn({
    required String email,
    required String password,
  });

  AppUser? user();

  AppToken? token();

  Future<void> signOut();

  Future<bool> checkUser();
}

class SignInError extends Error {}
