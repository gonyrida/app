/// UserModel - Supabase-compatible model for user profile
///
/// This model represents a user profile with all required fields.
/// It's designed to work with Supabase database.
class UserModel {
  /// UUID for Supabase (string format)
  String id;

  /// User's full name
  late String name;

  /// User's email address
  late String email;

  /// User's phone number (optional)
  String? phone;

  /// User's location (optional)
  String? location;

  /// User's bio/description (optional)
  String? bio;

  /// Local file path for avatar image (optional)
  String? avatarPath;

  /// Theme preference (light/dark/system)
  String themeMode = 'system'; // 'light', 'dark', 'system'

  /// Notification preferences
  bool notificationsEnabled = true;

  /// Account creation timestamp
  DateTime createdAt = DateTime.now();

  /// Last updated timestamp
  DateTime updatedAt = DateTime.now();

  /// Default constructor
  UserModel({
    String? id,
  }) : id = id ?? '';

  /// Factory constructor for creating users
  factory UserModel.create({
    required String name,
    required String email,
    String? phone,
    String? location,
    String? bio,
    String? avatarPath,
    String themeMode = 'system',
    bool notificationsEnabled = true,
  }) {
    final user = UserModel()
      ..name = name
      ..email = email
      ..phone = phone
      ..location = location
      ..bio = bio
      ..avatarPath = avatarPath
      ..themeMode = themeMode
      ..notificationsEnabled = notificationsEnabled;
    return user;
  }

  /// Copy with method for immutability
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? bio,
    String? avatarPath,
    String? themeMode,
    bool? notificationsEnabled,
  }) {
    final user = UserModel()
      ..id = id
      ..name = name ?? this.name
      ..email = email ?? this.email
      ..phone = phone ?? this.phone
      ..location = location ?? this.location
      ..bio = bio ?? this.bio
      ..avatarPath = avatarPath ?? this.avatarPath
      ..themeMode = themeMode ?? this.themeMode
      ..notificationsEnabled = notificationsEnabled ?? this.notificationsEnabled
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();
    return user;
  }

  /// Get theme mode as enum
  ThemeModePreference get themeModeEnum {
    switch (themeMode) {
      case 'light':
        return ThemeModePreference.light;
      case 'dark':
        return ThemeModePreference.dark;
      default:
        return ThemeModePreference.system;
    }
  }

  /// Set theme mode from enum
  set themeModeEnum(ThemeModePreference mode) {
    themeMode = mode.name;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Theme mode preference enum
enum ThemeModePreference {
  light,
  dark,
  system,
}

extension ThemeModePreferenceExtension on ThemeModePreference {
  String get name {
    switch (this) {
      case ThemeModePreference.light:
        return 'light';
      case ThemeModePreference.dark:
        return 'dark';
      case ThemeModePreference.system:
        return 'system';
    }
  }
}
