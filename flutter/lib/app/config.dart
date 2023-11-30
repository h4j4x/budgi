enum AuthProvider {
  supabase;

  static AuthProvider tryParse(String? value) {
    if (value?.isNotEmpty ?? false) {
      for (final authProvider in AuthProvider.values) {
        if (authProvider.name == value) {
          return authProvider;
        }
      }
    }
    return AuthProvider.values[0];
  }
}

class AppConfig {
  static int get textFieldMaxLength {
    return 200;
  }

  static int get passwordMinLength {
    return 6;
  }

  final AuthProvider authProvider;
  final String? supabaseUrl;
  final String? supabaseToken;

  AppConfig({
    String? authProviderStr,
    this.supabaseUrl,
    this.supabaseToken,
  }) : authProvider = AuthProvider.tryParse(authProviderStr);

  bool hasSupabaseAuth() {
    return authProvider == AuthProvider.supabase &&
        (supabaseUrl?.isNotEmpty ?? false) &&
        (supabaseToken?.isNotEmpty ?? false);
  }

  static AppConfig create() {
    const authProviderStr = bool.hasEnvironment('AUTH_PROVIDER')
        ? String.fromEnvironment('AUTH_PROVIDER')
        : null;
    const supabaseUrl = bool.hasEnvironment('SUPABASE_URL')
        ? String.fromEnvironment('SUPABASE_URL')
        : null;
    const supabaseToken = bool.hasEnvironment('SUPABASE_TOKEN')
        ? String.fromEnvironment('SUPABASE_TOKEN')
        : null;
    return AppConfig(
      authProviderStr: authProviderStr,
      supabaseUrl: supabaseUrl,
      supabaseToken: supabaseToken,
    );
  }
}
