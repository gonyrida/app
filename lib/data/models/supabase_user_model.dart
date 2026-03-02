/// Supabase User Profile Model
/// Matches the profiles table schema in Supabase
class SupabaseUserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? location;
  final String? bio;
  final String? avatarUrl;
  final String themeMode;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupabaseUserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.location,
    this.bio,
    this.avatarUrl,
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Supabase JSON data
  factory SupabaseUserModel.fromMap(Map<String, dynamic> map) {
    return SupabaseUserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      location: map['location'] as String?,
      bio: map['bio'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      themeMode: map['theme_mode'] as String? ?? 'system',
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convert to Supabase JSON data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'location': location,
      'bio': bio,
      'avatar_url': avatarUrl,
      'theme_mode': themeMode,
      'notifications_enabled': notificationsEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  SupabaseUserModel copyWith({
    String? name,
    String? phone,
    String? location,
    String? bio,
    String? avatarUrl,
    String? themeMode,
    bool? notificationsEnabled,
  }) {
    return SupabaseUserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to local UserModel for compatibility
  UserModel toLocalModel() {
    return UserModel()
      ..id = int.tryParse(id) ?? 0
      ..name = name
      ..email = email
      ..phone = phone
      ..location = location
      ..bio = bio
      ..avatarPath = avatarUrl
      ..themeMode = themeMode
      ..notificationsEnabled = notificationsEnabled
      ..createdAt = createdAt
      ..updatedAt = updatedAt;
  }

  @override
  String toString() {
    return 'SupabaseUserModel(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupabaseUserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Import the existing UserModel for compatibility
import '../features/task_management/domain/models/user_model.dart';
