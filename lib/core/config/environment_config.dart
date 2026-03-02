import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for Supabase
class EnvironmentConfig {
  static late String _supabaseUrl;
  static late String _supabaseAnonKey;
  static late String _siteUrl;
  static late String _redirectUrl;

  /// Load environment variables from .env file
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');

    _supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    _siteUrl = dotenv.env['SITE_URL'] ?? 'http://localhost:3000';
    _redirectUrl =
        dotenv.env['REDIRECT_URL'] ?? 'http://localhost:3000/auth/callback';

    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      throw Exception(
        'Missing Supabase configuration. Please check your .env file.\n'
        'Required: SUPABASE_URL, SUPABASE_ANON_KEY',
      );
    }

    if (kDebugMode) {
      print('Environment loaded:');
      print('  Supabase URL: $_supabaseUrl');
      print('  Site URL: $_siteUrl');
      print('  Redirect URL: $_redirectUrl');
    }
  }

  /// Get Supabase URL
  static String get supabaseUrl => _supabaseUrl;

  /// Get Supabase Anon Key
  static String get supabaseAnonKey => _supabaseAnonKey;

  /// Get Site URL for callbacks
  static String get siteUrl => _siteUrl;

  /// Get Redirect URL for auth callbacks
  static String get redirectUrl => _redirectUrl;

  /// Check if configuration is valid
  static bool get isValid =>
      _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;
}
