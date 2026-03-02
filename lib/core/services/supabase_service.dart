import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import '../config/environment_config.dart';

/// SupabaseService - Centralized Supabase configuration and client
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  late final SupabaseClient _client;
  SupabaseClient get client => _client;

  /// Initialize Supabase with your project credentials
  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: EnvironmentConfig.supabaseUrl,
        anonKey: EnvironmentConfig.supabaseAnonKey,
      );

      _client = Supabase.instance.client;

      if (kDebugMode) {
        print('Supabase initialized successfully');
        print('URL: ${EnvironmentConfig.supabaseUrl}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Supabase: $e');
      }
      rethrow;
    }
  }

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get current user ID
  String? get currentUserId => currentUser?.id;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('User signed in successfully: ${response.user?.email}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? location,
  }) async {
    try {
      final Map<String, String?> userData = {};
      if (name != null) userData['name'] = name;
      if (phone != null) userData['phone'] = phone;
      if (location != null) userData['location'] = location;

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData.isNotEmpty ? userData : null,
      );

      if (kDebugMode) {
        print('User signed up successfully: ${response.user?.email}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();

      if (kDebugMode) {
        print('User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);

      if (kDebugMode) {
        print('Password reset email sent to: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Password reset error: $e');
      }
      rethrow;
    }
  }

  /// Resend email confirmation
  Future<void> resendEmailConfirmation(String email) async {
    try {
      await _client.auth.resend(
        email: email,
        type: OtpType.signup,
      );

      if (kDebugMode) {
        print('Email confirmation resent to: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Resend confirmation error: $e');
      }
      rethrow;
    }
  }

  /// Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(data: metadata),
      );

      if (kDebugMode) {
        print('User metadata updated successfully');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Update user metadata error: $e');
      }
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Upload file to Supabase Storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    try {
      final response = await _client.storage.from(bucket).upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      if (kDebugMode) {
        print('File uploaded successfully: $response');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('File upload error: $e');
      }
      rethrow;
    }
  }

  /// Get public URL for file
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Delete file from Supabase Storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);

      if (kDebugMode) {
        print('File deleted successfully: $path');
      }
    } catch (e) {
      if (kDebugMode) {
        print('File deletion error: $e');
      }
      rethrow;
    }
  }
}
