import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/icon.dart';
import '../../model/user.dart';
import '../auth.dart';
import '../vendor/supabase.dart';

class AuthSupabaseService implements AuthService {
  final SupabaseConfig config;

  AuthSupabaseService({
    required this.config,
  });

  // https://supabase.com/docs/reference/dart/auth-signinwithoauth
  @override
  Future<bool> signInWithGithub(BuildContext context) {
    return config.supabase.auth.signInWithOAuth(
      Provider.github,
      redirectTo: kIsWeb ? null : 'com.sp1ke.budgi.flutter://sign-in-callback/',
      context: context,
      authScreenLaunchMode: LaunchMode.platformDefault,
    );
  }

  @override
  Stream<bool> authenticatedStream() {
    return config.supabase.auth.onAuthStateChange.map((state) {
      return state.session != null;
    });
  }

  // https://supabase.com/docs/reference/dart/auth-getuser
  @override
  AppUser? user() {
    final session = config.supabase.auth.currentSession;
    return session != null ? _User(session.user) : null;
  }
}

class _User implements AppUser {
  final User user;

  _User(this.user);

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
        (user.userMetadata!['full_name'] is String || user.userMetadata!['name'] is String)) {
      return user.userMetadata!['full_name'] as String? ?? user.userMetadata!['name'] as String;
    }
    return '-';
  }

  @override
  String get username {
    if (user.userMetadata != null &&
        (user.userMetadata!['preferred_username'] is String || user.userMetadata!['user_name'] is String)) {
      return user.userMetadata!['preferred_username'] as String? ?? user.userMetadata!['user_name'] as String;
    }
    return name;
  }

  @override
  Widget get icon {
    if (avatarUrl != null) {
      return ClipOval(
        child: Image.network(
          avatarUrl!,
          width: 30,
          height: 30,
          fit: BoxFit.scaleDown,
        ),
      );
    }
    return AppIcon.user;
  }
}
