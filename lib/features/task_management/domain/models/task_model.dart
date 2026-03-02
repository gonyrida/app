/// Priority levels for tasks
enum Priority {
  low,
  medium,
  high,
}

/// Priority extension for UI display
extension PriorityExtension on Priority {
  String get name {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  static Priority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        return Priority.medium;
    }
  }
}

/// TaskModel - Supabase-compatible model for task management
///
/// This model represents a task with all required fields for the
/// task management feature. It's designed to work with Supabase
/// database and includes userId for data isolation.
class TaskModel {
  /// UUID for Supabase (string format)
  String id;

  /// User email for data isolation (maps to Supabase user_id)
  late String userId;

  /// Task title (required)
  late String title;

  /// Task description (optional)
  String? description;

  /// Task priority level
  late Priority priority;

  /// Task category (work/personal/urgent/school)
  late String category;

  /// Due date for the task (optional)
  DateTime? dueDate;

  /// Completion status
  bool isCompleted = false;

  /// List of subtasks
  List<String> subtasks = [];

  /// Local file path for task image (optional)
  String? imagePath;

  /// Creation timestamp
  DateTime createdAt = DateTime.now();

  /// Last updated timestamp
  DateTime updatedAt = DateTime.now();

  /// Default constructor
  TaskModel({String? id}) : id = id ?? '';

  /// Factory constructor for creating tasks with userId
  factory TaskModel.create({
    required String userId,
    required String title,
    String? description,
    Priority priority = Priority.medium,
    String category = 'Personal',
    DateTime? dueDate,
    List<String>? subtasks,
    String? imagePath,
  }) {
    final task = TaskModel()
      ..userId = userId
      ..title = title
      ..description = description
      ..priority = priority
      ..category = category
      ..dueDate = dueDate
      ..subtasks = subtasks ?? []
      ..imagePath = imagePath;
    return task;
  }

  /// Factory constructor for creating tasks without userId (for backward compatibility)
  factory TaskModel.createLegacy({
    required String title,
    String? description,
    Priority priority = Priority.medium,
    String category = 'Personal',
    DateTime? dueDate,
    List<String>? subtasks,
    String? imagePath,
    String? id,
  }) {
    final task = TaskModel(id: id ?? '')
      ..userId = '' // Will be set later when user is available
      ..title = title
      ..description = description
      ..priority = priority
      ..category = category
      ..dueDate = dueDate
      ..subtasks = subtasks ?? []
      ..imagePath = imagePath;
    return task;
  }

  /// Copy with method for immutability
  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    Priority? priority,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    List<String>? subtasks,
    String? imagePath,
  }) {
    final task = TaskModel(id: id ?? this.id)
      ..userId = userId ?? this.userId
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..priority = priority ?? this.priority
      ..category = category ?? this.category
      ..dueDate = dueDate ?? this.dueDate
      ..isCompleted = isCompleted ?? this.isCompleted
      ..subtasks = subtasks ?? List.from(this.subtasks)
      ..imagePath = imagePath ?? this.imagePath
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();
    return task;
  }

  /// Toggle completion status
  void toggleComplete() {
    isCompleted = !isCompleted;
    updatedAt = DateTime.now();
  }

  /// Get priority color for UI
  int get priorityColorValue {
    switch (priority) {
      case Priority.high:
        return 0xFFF44336; // Red
      case Priority.medium:
        return 0xFFFF9800; // Orange
      case Priority.low:
        return 0xFFFFC107; // Yellow
    }
  }

  /// Convert to Supabase-compatible format
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id.toString(),
      'user_id': userId,
      'title': title,
      'description': description,
      'priority': priority.name.toLowerCase(),
      'category': category,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted,
      'subtasks': subtasks,
      'image_url': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from Supabase data
  factory TaskModel.fromSupabase(Map<String, dynamic> map) {
    final task = TaskModel(id: map['id'] as String? ?? '')
      ..userId = map['user_id'] as String? ?? ''
      ..title = map['title'] as String
      ..description = map['description'] as String?
      ..priority =
          PriorityExtension.fromString(map['priority'] as String? ?? 'medium')
      ..category = map['category'] as String? ?? 'Personal'
      ..dueDate = map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null
      ..isCompleted = map['is_completed'] as bool? ?? false
      ..subtasks = (map['subtasks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          []
      ..imagePath = map['image_url'] as String?
      ..createdAt = map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now()
      ..updatedAt = map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now();

    return task;
  }

  /// Get completion progress for subtasks
  double get subtaskProgress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    // For now, return 0 or 1 based on completion
    // Can be extended to track individual subtask completion
    return isCompleted ? 1.0 : 0.0;
  }

  /// Get formatted due date for display
  String? get formattedDueDate {
    if (dueDate == null) return null;
    return '${dueDate!.day.toString().padLeft(2, '0')}/${dueDate!.month.toString().padLeft(2, '0')}/${dueDate!.year}';
  }

  /// Get formatted due time for display
  String? get formattedDueTime {
    if (dueDate == null) return null;
    final hour = dueDate!.hour.toString().padLeft(2, '0');
    final minute = dueDate!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
