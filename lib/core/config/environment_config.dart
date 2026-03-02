import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for Supabase
class EnvironmentConfig {
  static late String _supabaseUrl;
  static late String _supabaseAnonKey;

  /// Load environment variables from .env file
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
    
    _supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      throw Exception(
        'Missing Supabase configuration. Please check your .env file.\n'
        'Required: SUPABASE_URL, SUPABASE_ANON_KEY',
      );
    }
  }

  /// Get Supabase URL
  static String get supabaseUrl => _supabaseUrl;

  /// Get Supabase Anon Key
  static String get supabaseAnonKey => _supabaseAnonKey;

  /// Check if configuration is valid
  static bool get isValid => 
      _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;
}
