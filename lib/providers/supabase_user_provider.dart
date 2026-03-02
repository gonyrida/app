import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../data/repositories/supabase_user_repository.dart';
import '../data/models/supabase_user_model.dart';
import '../features/task_management/domain/models/user_model.dart';
import '../core/services/supabase_service.dart';

/// Supabase User Providers
/// Replace the existing session-based user management with Supabase

/// Repository provider
final supabaseUserRepositoryProvider = Provider<SupabaseUserRepository>((ref) {
  return SupabaseUserRepository();
});

/// Current user profile provider
final supabaseUserProfileProvider = FutureProvider<SupabaseUserModel?>((ref) async {
  final repository = ref.read(supabaseUserRepositoryProvider);
  return await repository.getCurrentUserProfile();
});

/// User profile stream provider for real-time updates
final supabaseUserProfileStreamProvider = StreamProvider<SupabaseUserModel?>((ref) {
  final repository = ref.read(supabaseUserRepositoryProvider);
  return repository.watchUserProfile();
});

/// Authentication state provider
final supabaseAuthProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.instance.authStateChanges;
});

/// Current authenticated user provider
final supabaseCurrentUserProvider = Provider<User?>((ref) {
  return SupabaseService.instance.currentUser;
});

/// Authentication status provider
final supabaseIsAuthenticatedProvider = Provider<bool>((ref) {
  return SupabaseService.instance.isAuthenticated;
});

/// User service for authentication and profile management
class SupabaseUserService {
  final SupabaseUserRepository _repository;

  SupabaseUserService(this._repository);

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await SupabaseService.instance.signInWithEmail(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    return await SupabaseService.instance.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await SupabaseService.instance.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await SupabaseService.instance.resetPassword(email);
  }

  /// Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    final profile = await _repository.getCurrentUserProfile();
    return profile?.toLocalModel();
  }

  /// Update user profile
  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? location,
    String? bio,
    String? avatarUrl,
    String? themeMode,
    bool? notificationsEnabled,
  }) async {
    final updatedProfile = await _repository.updateUserProfile(
      name: name,
      phone: phone,
      location: location,
      bio: bio,
      avatarUrl: avatarUrl,
      themeMode: themeMode,
      notificationsEnabled: notificationsEnabled,
    );
    return updatedProfile.toLocalModel();
  }

  /// Upload avatar image
  Future<String> uploadAvatar(String filePath, String fileName) async {
    return await _repository.uploadAvatar(filePath, fileName);
  }

  /// Delete avatar
  Future<void> deleteAvatar(String avatarUrl) async {
    await _repository.deleteAvatar(avatarUrl);
  }

  /// Check if user profile exists
  Future<bool> userProfileExists() async {
    return await _repository.userProfileExists();
  }

  /// Create or update user profile
  Future<UserModel> saveUserProfile(UserModel user) async {
    final userId = SupabaseService.instance.currentUserId!;
    final supabaseUser = SupabaseUserModel(
      id: userId,
      email: user.email,
      name: user.name,
      phone: user.phone,
      location: user.location,
      bio: user.bio,
      avatarUrl: user.avatarPath,
      themeMode: user.themeMode,
      notificationsEnabled: user.notificationsEnabled,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(),
    );
    
    final savedProfile = await _repository.saveUserProfile(supabaseUser);
    return savedProfile.toLocalModel();
  }
}

/// User service provider
final supabaseUserServiceProvider = Provider<SupabaseUserService>((ref) {
  final repository = ref.read(supabaseUserRepositoryProvider);
  return SupabaseUserService(repository);
});

/// Bridge provider for compatibility with existing UserSessionProvider
/// This maintains the same interface while using Supabase backend
class SupabaseUserSessionProvider extends provider.ChangeNotifier {
  final SupabaseUserService _userService;
  String? _email;
  String? _name;
  String? _phone;
  bool _isLoggedIn = false;

  SupabaseUserSessionProvider(this._userService);

  String? get email => _email;
  String? get name => _name;
  String? get phone => _phone;
  bool get isLoggedIn => _isLoggedIn;

  /// Initialize with current auth state
  Future<void> initialize() async {
    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser != null) {
      _email = currentUser.email;
      _isLoggedIn = true;
      
      // Clear previous session data first
      _name = null;
      _phone = null;
      
      // Load fresh profile data for current user
      final profile = await _userService.getCurrentUserProfile();
      if (profile != null) {
        _name = profile.name;
        _phone = profile.phone;
      }
      
      notifyListeners();
    } else {
      // Clear all session data when no user is logged in
      _clearSessionData();
    }
  }

  /// Clear all session data
  void _clearSessionData() {
    _email = null;
    _name = null;
    _phone = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  /// Save user session (for compatibility)
  Future<void> saveSession({
    required String email,
    String? name,
    String? phone,
  }) async {
    _email = email;
    _name = name;
    _phone = phone;
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Update profile info
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    await _userService.updateUserProfile(
      name: name,
      phone: phone,
    );
    
    if (name != null) _name = name;
    if (phone != null) _phone = phone;
    if (email != null) _email = email;
    
    notifyListeners();
  }

  /// Clear session on logout
  Future<void> clearSession() async {
    await _userService.signOut();
    _clearSessionData();
  }
}

/// Supabase session provider
final supabaseSessionProvider = provider.Provider<SupabaseUserSessionProvider>((ref) {
  final userService = ref.read(supabaseUserServiceProvider);
  return SupabaseUserSessionProvider(userService);
});

/// Import required types
import 'package:supabase_flutter/supabase_flutter.dart';
