import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  final String url;
  final String token;

  SupabaseConfig({
    required this.url,
    required this.token,
  });

  // https://supabase.com/docs/reference/dart/initializing
  Future<void> initialize() {
    return Supabase.initialize(
      url: url,
      anonKey: token,
    );
  }

  SupabaseClient get supabase {
    return Supabase.instance.client;
  }
}
