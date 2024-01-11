enum DataProvider {
  supabase,
  spring;

  static DataProvider tryParse(String? value) {
    if (value?.isNotEmpty ?? false) {
      for (final dataProvider in DataProvider.values) {
        if (dataProvider.name == value) {
          return dataProvider;
        }
      }
    }
    return DataProvider.values[0];
  }
}

class AppConfig {
  static int get textFieldMaxLength {
    return 200;
  }

  static int get passwordMinLength {
    return 6;
  }

  final DataProvider dataProvider;
  final String? apiUrl;
  final String? apiToken;

  AppConfig({
    required this.dataProvider,
    this.apiUrl,
    this.apiToken,
  });

  bool hasSupabaseProvider() {
    return dataProvider == DataProvider.supabase && (apiUrl?.isNotEmpty ?? false) && (apiToken?.isNotEmpty ?? false);
  }

  bool hasSpringProvider() {
    return dataProvider == DataProvider.spring && (apiUrl?.isNotEmpty ?? false);
  }

  static AppConfig create() {
    const dataProviderStr = bool.hasEnvironment('DATA_PROVIDER') ? String.fromEnvironment('DATA_PROVIDER') : null;
    final dataProvider = DataProvider.tryParse(dataProviderStr);

    String? apiUrl;
    String? apiToken;
    if (dataProvider == DataProvider.supabase) {
      apiUrl = const String.fromEnvironment('SUPABASE_URL');
      apiToken = const String.fromEnvironment('SUPABASE_TOKEN');
    } else if (dataProvider == DataProvider.spring) {
      apiUrl = const String.fromEnvironment('SPRING_URL');
    }

    return AppConfig(
      dataProvider: dataProvider,
      apiUrl: apiUrl,
      apiToken: apiToken,
    );
  }
}
