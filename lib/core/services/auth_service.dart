import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'supabase_service.dart';
import '../../features/task_management/application/task_providers.dart';

/// AuthService - Centralized authentication and data management
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  /// Sign out current user and clear all cached data
  Future<void> signOutAndClearData(Ref ref) async {
    try {
      // Clear all task data before signing out
      final taskService = ref.read(taskServiceProvider);
      taskService.clearAllTaskData();

      // Sign out from Supabase
      await SupabaseService.instance.signOut();

      if (kDebugMode) {
        print('User signed out and all data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign out and data cleanup: $e');
      }
      rethrow;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => SupabaseService.instance.isAuthenticated;

  /// Get current user ID
  String? get currentUserId => SupabaseService.instance.currentUserId;

  /// Get current user
  get currentUser => SupabaseService.instance.currentUser;
}

/// AuthService provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});
