import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/icon.dart';
import '../../model/domain/user.dart';
import '../../model/token.dart';
import '../auth.dart';
import 'config.dart';

class AuthSupabaseService extends AuthService {
  final SupabaseConfig config;

  AuthSupabaseService({
    required this.config,
  });

  // https://supabase.com/docs/reference/dart/auth-signinwithpassword
  @override
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await config.supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.session != null;
    } on AuthException catch (_) {
      throw SignInError();
    } catch (e) {
      debugPrint('Unexpected error $e');
      throw SignInError();
    }
  }

  // https://supabase.com/docs/reference/dart/auth-signinwithoauth
  @override
  Future<bool> signInWithGithub() {
    return config.supabase.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: kIsWeb ? null : 'com.sp1ke.budgi.flutter://sign-in-callback/',
      authScreenLaunchMode: LaunchMode.platformDefault,
    );
  }

  @override
  Stream<bool> authenticatedStream() {
    final listenedEvents = <AuthChangeEvent>[
      AuthChangeEvent.signedIn,
      AuthChangeEvent.signedOut,
      AuthChangeEvent.initialSession,
      AuthChangeEvent.tokenRefreshed,
    ];
    return config.supabase.auth.onAuthStateChange.where((state) {
      return listenedEvents.contains(state.event);
    }).map((state) {
      final hasSession = state.session != null && !(state.session!.isExpired);
      debugPrint(
          'Supabase onAuthStateChange event: ${state.event}, has session: $hasSession');
      return hasSession;
    });
  }

  // https://supabase.com/docs/reference/dart/auth-getuser
  @override
  AppUser? user() {
    final session = config.supabase.auth.currentSession;
    return session != null ? _User(session.user) : null;
  }

  @override
  Future<void> signOut() {
    return config.supabase.auth.signOut();
  }

  @override
  AppToken? token() {
    return null;
  }
}

class _User implements AppUser {
  final User user;

  _User(this.user);

  @override
  String get id {
    return user.id;
  }

  @override
  String? get avatarUrl {
    if (user.userMetadata != null) {
      return user.userMetadata!['avatar_url'] as String?;
    }
    return null;
  }

  @override
  String? get email {
    if (user.userMetadata != null && user.userMetadata!['email'] is String) {
      return user.userMetadata!['email'] as String;
    }
    return user.email;
  }

  @override
  String get name {
    if (user.userMetadata != null &&
        (user.userMetadata!['full_name'] is String ||
            user.userMetadata!['name'] is String)) {
      return user.userMetadata!['full_name'] as String? ??
          user.userMetadata!['name'] as String;
    }
    return '-';
  }

  @override
  String get username {
    if (user.userMetadata != null &&
        (user.userMetadata!['preferred_username'] is String ||
            user.userMetadata!['user_name'] is String)) {
      return user.userMetadata!['preferred_username'] as String? ??
          user.userMetadata!['user_name'] as String;
    }
    return name;
  }

  @override
  Widget icon({double? size, Color? color}) {
    if (avatarUrl != null) {
      return ClipOval(
        child: Image.network(
          avatarUrl!,
          width: size ?? 30,
          height: size ?? 30,
          color: color,
          fit: BoxFit.scaleDown,
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: Center(child: AppIcon.user(size: size, color: color)),
    );
  }

  @override
  String get usernameOrEmail {
    if (username.length > 1) {
      return username;
    }
    return email ?? '-';
  }
}
