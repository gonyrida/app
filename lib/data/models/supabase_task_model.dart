import 'package:flutter/foundation.dart';
import '../../features/task_management/domain/models/task_model.dart';

/// Supabase Task Model
/// Matches the tasks table schema in Supabase
class SupabaseTaskModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String priority;
  final String category;
  final DateTime? dueDate;
  final bool isCompleted;
  final List<String> subtasks;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupabaseTaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.priority = 'medium',
    this.category = 'Personal',
    this.dueDate,
    this.isCompleted = false,
    this.subtasks = const [],
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Supabase JSON data
  factory SupabaseTaskModel.fromMap(Map<String, dynamic> map) {
    debugPrint('Creating SupabaseTaskModel from map: $map');

    return SupabaseTaskModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      priority: map['priority'] as String? ?? 'medium',
      category: map['category'] as String? ?? 'Personal',
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      isCompleted: map['is_completed'] as bool? ?? false,
      subtasks: (map['subtasks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convert to Supabase JSON data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted,
      'subtasks': subtasks,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  SupabaseTaskModel copyWith({
    String? title,
    String? description,
    String? priority,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    List<String>? subtasks,
    String? imageUrl,
  }) {
    return SupabaseTaskModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert from local TaskModel
  factory SupabaseTaskModel.fromLocalModel(TaskModel task, String userId) {
    return SupabaseTaskModel(
      id: task.id.toString(),
      userId: userId,
      title: task.title,
      description: task.description,
      priority: task.priority.name,
      category: task.category,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      subtasks: task.subtasks,
      imageUrl: task.imagePath,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  /// Convert to local TaskModel for compatibility
  TaskModel toLocalModel() {
    final task = TaskModel()
      ..id = id
      ..title = title
      ..description = description
      ..priority = _parsePriority(priority)
      ..category = category
      ..dueDate = dueDate
      ..isCompleted = isCompleted
      ..subtasks = subtasks
      ..imagePath = imageUrl
      ..createdAt = createdAt
      ..updatedAt = updatedAt;

    return task;
  }

  /// Parse priority string to enum
  Priority _parsePriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'high':
        return Priority.high;
      default:
        return Priority.medium;
    }
  }

  /// Get priority as enum
  Priority get priorityEnum {
    switch (priority.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'high':
        return Priority.high;
      default:
        return Priority.medium;
    }
  }

  /// Get formatted due date string (same as local model)
  String get formattedDueDate {
    if (dueDate == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);

    final difference = due.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 0 && difference < 7) {
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      return weekdays[dueDate!.weekday - 1];
    }

    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  @override
  String toString() {
    return 'SupabaseTaskModel(id: $id, title: $title, priority: $priority, completed: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupabaseTaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
