import '../models/task_model.dart';

final List<TaskModel> sampleTasks = [
  TaskModel.create(
    userId: 'sample-user-1',
    title: 'Design system documentation',
    category: 'Design',
    priority: Priority.high,
    dueDate: DateTime.now().add(const Duration(hours: 2)),
    imagePath:
        'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=100&h=100&fit=crop',
  ),
  TaskModel.create(
    userId: 'sample-user-1',
    title: 'Review pull requests',
    category: 'Development',
    priority: Priority.medium,
    dueDate: DateTime.now().add(const Duration(hours: 6)),
    imagePath:
        'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=100&h=100&fit=crop',
  ),
  TaskModel.create(
    userId: 'sample-user-1',
    title: 'Team standup meeting',
    category: 'Meeting',
    priority: Priority.low,
    dueDate: DateTime.now().add(const Duration(hours: 1)),
    imagePath:
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=100&h=100&fit=crop',
  )..isCompleted = true,
  TaskModel.create(
    userId: 'sample-user-1',
    title: 'Update user interface mockups',
    category: 'Design',
    priority: Priority.medium,
    dueDate: DateTime.now().add(const Duration(days: 1, hours: 3)),
    imagePath:
        'https://images.unsplash.com/photo-1586717791821-3f44a563fa4c?w=100&h=100&fit=crop',
  ),
  TaskModel.create(
    userId: 'sample-user-1',
    title: 'Fix navigation bug',
    category: 'Development',
    priority: Priority.high,
    dueDate: DateTime.now().add(const Duration(days: 1, hours: 7)),
    imagePath:
        'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=100&h=100&fit=crop',
  ),
  TaskModel.create(
    userId: 'sample-user-1',
    title: 'Client presentation prep',
    category: 'Meeting',
    priority: Priority.high,
    dueDate: DateTime.now().add(const Duration(days: 2, hours: 5)),
    imagePath:
        'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=100&h=100&fit=crop',
  ),
  TaskModel.create(
    userId: 'sample-user-1',
    title: 'Code review session',
    category: 'Development',
    priority: Priority.medium,
    dueDate: DateTime.now().add(const Duration(days: 2, hours: 8)),
    imagePath:
        'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=100&h=100&fit=crop',
  )..isCompleted = true,
];

class ApiAdapter {
  static Future<List<TaskModel>> fetchTasks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return empty list for new users - no sample data
    return [];
  }

  static Future<void> syncTasks(List<TaskModel> tasks) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
