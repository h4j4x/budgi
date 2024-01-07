enum AuthProvider {
  supabase,
  spring;

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
  final String? apiUrl;
  final String? apiToken;

  AppConfig({
    required this.authProvider,
    this.apiUrl,
    this.apiToken,
  });

  bool isSupabase() {
    return authProvider == AuthProvider.supabase &&
        (apiUrl?.isNotEmpty ?? false) &&
        (apiToken?.isNotEmpty ?? false);
  }

  bool isSpring() {
    return authProvider == AuthProvider.spring && (apiUrl?.isNotEmpty ?? false);
  }

  static AppConfig create() {
    const authProviderStr = bool.hasEnvironment('AUTH_PROVIDER')
        ? String.fromEnvironment('AUTH_PROVIDER')
        : null;
    final authProvider = AuthProvider.tryParse(authProviderStr);

    String? apiUrl;
    String? apiToken;
    if (authProvider == AuthProvider.supabase) {
      apiUrl = const String.fromEnvironment('SUPABASE_URL');
      apiToken = const String.fromEnvironment('SUPABASE_TOKEN');
    } else if (authProvider == AuthProvider.spring) {
      apiUrl = const String.fromEnvironment('SPRING_URL');
    }

    return AppConfig(
      authProvider: authProvider,
      apiUrl: apiUrl,
      apiToken: apiToken,
    );
  }
}
