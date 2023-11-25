import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      redirectTo: 'com.sp1ke.budgi.flutter://sign-in-callback',
      context: context,
      authScreenLaunchMode: LaunchMode.platformDefault,
    );
  }

  // https://supabase.com/docs/reference/dart/auth-getuser
  @override
  String? user() {
    final user = config.supabase.auth.currentUser;
    return user?.id;
  }
}
