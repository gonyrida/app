import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/supabase_user_model.dart';

/// Supabase User Repository
/// Handles all user-related database operations with Supabase
class SupabaseUserRepository {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Get current user profile
  Future<SupabaseUserModel?> getCurrentUserProfile() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return null;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      if (response == null) return null;

      return SupabaseUserModel.fromMap(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }

  /// Create or update user profile
  Future<SupabaseUserModel> saveUserProfile(SupabaseUserModel user) async {
    try {
      final response = await _client
          .from('profiles')
          .upsert(user.toMap())
          .select()
          .single();

      if (kDebugMode) {
        print('User profile saved successfully');
      }

      return SupabaseUserModel.fromMap(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user profile: $e');
      }
      rethrow;
    }
  }

  /// Update user profile fields
  Future<SupabaseUserModel> updateUserProfile({
    String? name,
    String? phone,
    String? location,
    String? bio,
    String? avatarUrl,
    String? themeMode,
    bool? notificationsEnabled,
  }) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (location != null) updateData['location'] = location;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (themeMode != null) updateData['theme_mode'] = themeMode;
      if (notificationsEnabled != null) updateData['notifications_enabled'] = notificationsEnabled;

      final response = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      if (kDebugMode) {
        print('User profile updated successfully');
      }

      return SupabaseUserModel.fromMap(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  /// Upload avatar image to Supabase Storage
  Future<String> uploadAvatar(String filePath, String fileName) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final fileBytes = await _client.storage.from('avatars').download(filePath);
      
      final path = 'users/$userId/avatars/$fileName';
      await _client.storage.from('avatars').upload(
        path,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = _client.storage.from('avatars').getPublicUrl(path);

      if (kDebugMode) {
        print('Avatar uploaded successfully: $publicUrl');
      }

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading avatar: $e');
      }
      rethrow;
    }
  }

  /// Delete avatar from Supabase Storage
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Extract path from URL
      final uri = Uri.parse(avatarUrl);
      final path = uri.pathSegments.last;

      await _client.storage.from('avatars').remove(['users/$userId/avatars/$path']);

      if (kDebugMode) {
        print('Avatar deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting avatar: $e');
      }
      rethrow;
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('profiles').delete().eq('id', userId);

      if (kDebugMode) {
        print('User profile deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user profile: $e');
      }
      rethrow;
    }
  }

  /// Stream user profile changes
  Stream<SupabaseUserModel?> watchUserProfile() {
    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) return Stream.value(null);

    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? SupabaseUserModel.fromMap(data.first) : null);
  }

  /// Check if user profile exists
  Future<bool> userProfileExists() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return false;

      final count = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .count();

      return count > 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user profile existence: $e');
      }
      return false;
    }
  }
}
