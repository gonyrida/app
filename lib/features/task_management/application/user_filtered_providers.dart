import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;

import '../domain/models/task_model.dart';
import '../application/task_providers.dart';
import '../../../providers/user_session_provider.dart';

/// Provider that filters tasks by current user
final userTasksProvider = Provider<List<TaskModel>>((ref) {
  final allTasks = ref.watch(allTasksProvider);
  final container = provider_pkg.ProviderContainer();
  final sessionProvider =
      container.read(provider_pkg.Provider.of<UserSessionProvider>);
  final currentUserId = sessionProvider.email ?? '';

  if (currentUserId.isEmpty) {
    return [];
  }

  // Filter tasks by userId - this will work once we regenerate the model
  // For now, return all tasks (temporary)
  return allTasks;
});

/// Provider that filters tasks by current user and completion status
final userFilteredTasksProvider =
    Provider.family<List<TaskModel>, TaskFilter>((ref, filter) {
  final userTasks = ref.watch(userTasksProvider);

  switch (filter) {
    case TaskFilter.pending:
      return userTasks.where((task) => !task.isCompleted).toList();
    case TaskFilter.completed:
      return userTasks.where((task) => task.isCompleted).toList();
    case TaskFilter.all:
    default:
      return userTasks;
  }
});

/// Provider for user-specific task statistics
final userTaskStatsProvider = Provider((ref) {
  final userTasks = ref.watch(userTasksProvider);

  final total = userTasks.length;
  final completed = userTasks.where((task) => task.isCompleted).length;
  final pending = total - completed;
  final highPriority = userTasks
      .where((task) => !task.isCompleted && task.priority == Priority.high)
      .length;

  return TaskStats(
    total: total,
    completed: completed,
    pending: pending,
    highPriority: highPriority,
  );
});
