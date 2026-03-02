import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
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

      final response =
          await _client.from('profiles').select().eq('id', userId).single();

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
      final response =
          await _client.from('profiles').upsert(user.toMap()).select().single();

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
    print('🔥 === REPOSITORY: updateUserProfile START ===');

    try {
      final userId = SupabaseService.instance.currentUserId;
      print('🔥 Current user ID: $userId');

      if (userId == null) {
        print('🔥 ERROR: User not authenticated');
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{};

      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
        print('🔥 Adding name to update: "$name"');
      } else {
        print('🔥 Skipping name update (null or empty)');
      }

      if (phone != null && phone.isNotEmpty) {
        updateData['phone'] = phone;
        print('🔥 Adding phone to update: "$phone"');
      } else {
        print('🔥 Skipping phone update (null or empty)');
      }

      if (location != null && location.isNotEmpty) {
        updateData['location'] = location;
        print('🔥 Adding location to update: "$location"');
      } else {
        print('🔥 Skipping location update (null or empty)');
      }

      if (bio != null && bio.isNotEmpty) {
        updateData['bio'] = bio;
        print('🔥 Adding bio to update: "$bio"');
      } else {
        print('🔥 Skipping bio update (null or empty)');
      }

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        updateData['avatar_url'] = avatarUrl;
        print('🔥 Adding avatar_url to update: "$avatarUrl"');
      } else {
        print('🔥 Skipping avatar_url update (null or empty)');
      }

      if (themeMode != null) {
        updateData['theme_mode'] = themeMode;
        print('🔥 Adding theme_mode to update: "$themeMode"');
      }

      if (notificationsEnabled != null) {
        updateData['notifications_enabled'] = notificationsEnabled;
        print(
            '🔥 Adding notifications_enabled to update: $notificationsEnabled');
      }

      print('🔥 Final update data: $updateData');

      if (updateData.isEmpty) {
        print('🔥 WARNING: No data to update!');
        throw Exception('No valid data to update');
      }

      print('🔥 Executing database update...');

      // First check if profile exists
      print('🔥 Checking if profile exists for user: $userId');
      final checkResponse =
          await _client.from('profiles').select('id').eq('id', userId);

      print('🔥 Profile check result: ${checkResponse}');
      print('🔥 Number of profiles found: ${checkResponse.length}');

      if (checkResponse.isEmpty) {
        print(
            '🔥 WARNING: No profile found for user $userId - creating new profile');
        // Create profile if it doesn't exist
        final createResponse = await _client
            .from('profiles')
            .insert({
              'id': userId,
              'email': SupabaseService.instance.currentUser?.email ?? '',
              'name': name ?? 'User',
              ...updateData,
            })
            .select()
            .single();
        print('🔥 Profile created: $createResponse');
        final result = SupabaseUserModel.fromMap(createResponse);
        print('🔥 === REPOSITORY: createUserProfile SUCCESS ===');
        return result;
      }

      final response = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      print('🔥 Database response: $response');

      if (kDebugMode) {
        print('User profile updated successfully');
      }

      final result = SupabaseUserModel.fromMap(response);
      print('🔥 === REPOSITORY: updateUserProfile SUCCESS ===');
      return result;
    } catch (e) {
      print('🔥 === REPOSITORY: updateUserProfile ERROR ===');
      print('🔥 Error: $e');
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

      final path = 'users/$userId/avatars/$fileName';

      // Read file bytes from local file path
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();

      await _client.storage.from('avatars').uploadBinary(
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

      await _client.storage
          .from('avatars')
          .remove(['users/$userId/avatars/$path']);

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
        .map((data) =>
            data.isNotEmpty ? SupabaseUserModel.fromMap(data.first) : null);
  }

  /// Check if user profile exists
  Future<bool> userProfileExists() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return false;

      final response =
          await _client.from('profiles').select('id').eq('id', userId).count();

      return response.count > 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user profile existence: $e');
      }
      return false;
    }
  }
}
