import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration. For production, pass URL and anon key via --dart-define
/// to avoid committing secrets:
///   flutter build apk --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key
/// If not set, falls back to [defaultSupabaseUrl] and [defaultSupabaseAnonKey] (dev only).
class SupabaseConfig {
  static const String _envUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String _envAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Defaults for local development only. Do not use in production.
  static const String defaultSupabaseUrl = 'https://mrawbdocoobrjfxdjeud.supabase.co';
  static const String defaultSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yYXdiZG9jb29icmpmeGRqZXVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzMDM2OTMsImV4cCI6MjA4Nzg3OTY5M30.yhCXLg4BcxEyTWkZjOCfO8O4ka_td3irTbU7Kr7atTc';

  static String get supabaseUrl => _envUrl.isNotEmpty ? _envUrl : defaultSupabaseUrl;
  static String get supabaseAnonKey => _envAnonKey.isNotEmpty ? _envAnonKey : defaultSupabaseAnonKey;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
