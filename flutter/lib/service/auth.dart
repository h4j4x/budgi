import 'dart:async';

import '../model/domain/user.dart';
import '../model/error/validation.dart';
import '../model/token.dart';

abstract class AuthService {
  /// @throws SignInError
  Future<bool> signIn({
    required String email,
    required String password,
  });

  /// @throws SignInError
  Future<bool> signInWithGithub();

  Stream<bool> authenticatedStream();

  AppUser? user();

  AppToken? token();

  Future<void> signOut();

  Future<AppUser> fetchUser<T>({required T errorIfMissing}) async {
    final appUser = user();
    if (appUser != null) {
      return Future.value(appUser);
    }
    throw Future.error(ValidationError<T>({
      'user': errorIfMissing,
    }));
  }
}

class SignInError extends Error {}
