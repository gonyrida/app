import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/supabase_task_repository.dart';
import '../domain/models/task_model.dart';
import '../../../../core/services/supabase_service.dart';

part 'task_providers.g.dart';

/// Provider for Supabase task repository
@riverpod
SupabaseTaskRepository supabaseTaskRepository(SupabaseTaskRepositoryRef ref) {
  return SupabaseTaskRepository();
}

/// Provider for all tasks from Supabase
@riverpod
Future<List<TaskModel>> allTasks(AllTasksRef ref) async {
  final repository = ref.watch(supabaseTaskRepositoryProvider);
  final currentUserId = SupabaseService.instance.currentUserId;

  if (currentUserId == null) {
    if (kDebugMode) {
      print('User not authenticated - returning empty task list');
    }
    return [];
  }

  try {
    final tasks = await repository.getAllTasks();

    // Double-filter tasks by user ID for additional security
    final userTasks =
        tasks.where((task) => task.userId == currentUserId).toList();

    if (kDebugMode) {
      print(
          'All tasks loaded for user $currentUserId: ${userTasks.length} tasks');
    }
    return userTasks;
  } catch (e) {
    if (kDebugMode) {
      print('Error loading all tasks: $e');
    }
    return [];
  }
}

/// Provider for filtered tasks based on completion status
@riverpod
Future<List<TaskModel>> filteredTasks(
  FilteredTasksRef ref, {
  required TaskFilter filter,
  String searchQuery = '',
}) async {
  final repository = ref.watch(supabaseTaskRepositoryProvider);
  final currentUserId = SupabaseService.instance.currentUserId;

  if (currentUserId == null) {
    if (kDebugMode) {
      print('User not authenticated - returning empty filtered task list');
    }
    return [];
  }

  try {
    List<TaskModel> tasks;

    // Get tasks based on filter
    switch (filter) {
      case TaskFilter.pending:
        tasks = await repository.getTasksByStatus(isCompleted: false);
        break;
      case TaskFilter.completed:
        tasks = await repository.getTasksByStatus(isCompleted: true);
        break;
      case TaskFilter.all:
      default:
        tasks = await repository.getAllTasks();
        break;
    }

    // Apply search filter if provided
    if (searchQuery.isNotEmpty) {
      tasks = await repository.searchTasks(searchQuery);
    }

    // Double-filter tasks by user ID for additional security
    final userTasks =
        tasks.where((task) => task.userId == currentUserId).toList();

    // Sort by priority (high -> medium -> low) and then by due date
    userTasks.sort((a, b) {
      // First sort by completion (pending first)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      // Then by priority (high = 2, medium = 1, low = 0)
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;

      // Then by due date (earlier first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;

      return 0;
    });

    return userTasks;
  } catch (e) {
    if (kDebugMode) {
      print('Error loading filtered tasks: $e');
    }
    return [];
  }
}

/// Provider for today's tasks
@riverpod
Future<List<TaskModel>> todaysTasks(TodaysTasksRef ref) async {
  final repository = ref.watch(supabaseTaskRepositoryProvider);
  final currentUserId = SupabaseService.instance.currentUserId;

  if (currentUserId == null) {
    if (kDebugMode) {
      print('User not authenticated - returning empty today task list');
    }
    return [];
  }

  try {
    final allTasks = await repository.getAllTasks();

    // Double-filter tasks by user ID for additional security
    final userTasks =
        allTasks.where((task) => task.userId == currentUserId).toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (kDebugMode) {
      print(
          'DEBUG: Total tasks loaded for user $currentUserId: ${userTasks.length}');
      print('DEBUG: Today: $today, Tomorrow: $tomorrow');
    }

    final todayTasksList = userTasks.where((task) {
      if (task.isCompleted) return false;
      if (task.dueDate == null) return false;

      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );

      final isToday = taskDate.isAtSameMomentAs(today) ||
          taskDate.isAtSameMomentAs(tomorrow);

      if (kDebugMode) {
        print(
            'DEBUG: Today task check - Task ID: ${task.id}, Due: ${task.dueDate}, IsToday: $isToday');
      }

      return isToday;
    }).toList();

    if (kDebugMode) {
      print('DEBUG: Today\'s tasks found: ${todayTasksList.length}');
    }

    return todayTasksList;
  } catch (e) {
    if (kDebugMode) {
      print('Error loading today\'s tasks: $e');
    }
    return [];
  }
}

/// Provider for task statistics
@riverpod
Future<TaskStats> taskStats(TaskStatsRef ref) async {
  final repository = ref.watch(supabaseTaskRepositoryProvider);
  final currentUserId = SupabaseService.instance.currentUserId;

  if (currentUserId == null) {
    if (kDebugMode) {
      print('User not authenticated - returning empty task stats');
    }
    return const TaskStats(
      total: 0,
      completed: 0,
      pending: 0,
      highPriority: 0,
    );
  }

  try {
    // Use the repository's getTaskStats method for consistency
    final statsMap = await repository.getTaskStats();

    if (kDebugMode) {
      print('DEBUG: Task stats from repository: $statsMap');
    }

    return TaskStats(
      total: statsMap['total'] ?? 0,
      completed: statsMap['completed'] ?? 0,
      pending: statsMap['pending'] ?? 0,
      highPriority: statsMap['high_priority'] ?? 0,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error loading task stats: $e');
    }
    return const TaskStats(
      total: 0,
      completed: 0,
      pending: 0,
      highPriority: 0,
    );
  }
}

/// Provider for a single task by ID
@riverpod
Future<TaskModel?> taskById(TaskByIdRef ref, String id) async {
  final repository = ref.watch(supabaseTaskRepositoryProvider);

  try {
    return await repository.getTaskById(id);
  } catch (e) {
    if (kDebugMode) {
      print('Error loading task by ID: $e');
    }
    return null;
  }
}

/// Service for task operations (add, update, delete)
class TaskService {
  final Ref ref;

  TaskService(this.ref);

  /// Add a new task to Supabase
  Future<bool> addTask(TaskModel task) async {
    try {
      final repository = ref.read(supabaseTaskRepositoryProvider);
      final currentUserId = SupabaseService.instance.currentUserId;

      if (currentUserId == null) {
        if (kDebugMode) {
          print('ERROR: User not authenticated - cannot add task');
        }
        return false;
      }

      // Ensure task has correct user ID
      if (task.userId != currentUserId) {
        task.userId = currentUserId;
      }

      // Debug: Log the task operation (without sensitive data)
      if (kDebugMode) {
        print('DEBUG: Creating task with priority: ${task.priority.name}');
        print('DEBUG: Task category: ${task.category}');
      }

      await repository.createTask(task);

      // Invalidate related providers to refresh UI
      ref.invalidate(allTasksProvider);
      ref.invalidate(taskStatsProvider);
      ref.invalidate(filteredTasksProvider);
      ref.invalidate(todaysTasksProvider);

      return true;
    } catch (e, stackTrace) {
      // Log error in all modes for debugging
      print('ERROR adding task: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Update an existing task
  Future<bool> updateTask(TaskModel task) async {
    try {
      final repository = ref.read(supabaseTaskRepositoryProvider);
      await repository.updateTask(task);

      // Invalidate related providers
      ref.invalidate(allTasksProvider);
      ref.invalidate(taskStatsProvider);
      ref.invalidate(taskByIdProvider(task.id));
      ref.invalidate(filteredTasksProvider);
      ref.invalidate(todaysTasksProvider);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating task: $e');
      }
      return false;
    }
  }

  /// Toggle task completion status
  Future<bool> toggleTaskCompletion(String taskId) async {
    try {
      final repository = ref.read(supabaseTaskRepositoryProvider);
      await repository.toggleTaskCompletion(taskId);

      // Invalidate related providers
      ref.invalidate(allTasksProvider);
      ref.invalidate(taskStatsProvider);
      ref.invalidate(taskByIdProvider(taskId));
      ref.invalidate(filteredTasksProvider);
      ref.invalidate(todaysTasksProvider);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling task: $e');
      }
      return false;
    }
  }

  /// Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      final repository = ref.read(supabaseTaskRepositoryProvider);
      await repository.deleteTask(taskId);

      // Invalidate related providers
      ref.invalidate(allTasksProvider);
      ref.invalidate(taskStatsProvider);
      ref.invalidate(filteredTasksProvider);
      ref.invalidate(todaysTasksProvider);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting task: $e');
      }
      return false;
    }
  }

  /// Refresh all tasks
  Future<void> refreshTasks() async {
    ref.invalidate(allTasksProvider);
    ref.invalidate(taskStatsProvider);
    ref.invalidate(filteredTasksProvider);
    ref.invalidate(todaysTasksProvider);
  }

  /// Clear all cached task data (call this on user logout)
  void clearAllTaskData() {
    ref.invalidate(allTasksProvider);
    ref.invalidate(taskStatsProvider);
    ref.invalidate(filteredTasksProvider);
    ref.invalidate(todaysTasksProvider);

    // Invalidate all taskById providers
    // Note: Riverpod doesn't provide a way to invalidate all family providers at once
    // This will be handled by the individual task invalidations above

    if (kDebugMode) {
      print('All task data cleared from cache');
    }
  }
}

/// Notifier for task operations (add, update, delete)
class TaskNotifier extends Notifier<List<TaskModel>> {
  @override
  List<TaskModel> build() {
    return [];
  }

  /// Add a new task to Supabase
  Future<bool> addTask(TaskModel task) async {
    try {
      final repository = ref.read(supabaseTaskRepositoryProvider);
      await repository.createTask(task);

      // Invalidate related providers to refresh UI
      ref.invalidate(allTasksProvider);
      ref.invalidate(taskStatsProvider);
      ref.invalidate(filteredTasksProvider);
      ref.invalidate(todaysTasksProvider);

      return true;
    } catch (e, stackTrace) {
      // Log error in all modes for debugging
      print('ERROR adding task: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Update an existing task
  Future<bool> updateTask(TaskModel task) async {
    try {
      final repository = ref.read(supabaseTaskRepositoryProvider);
      await repository.updateTask(task);

      // Invalidate related providers
      ref.invalidate(allTasksProvider);
      ref.invalidate(taskStatsProvider);
      ref.invalidate(taskByIdProvider(task.id));
      ref.invalidate(filteredTasksProvider);
      ref.invalidate(todaysTasksProvider);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating task: $e');
      }
      return false;
    }
  }

  /// Toggle task completion status
  Future<bool> toggleTaskCompletion(String taskId) async {
    try {
      final repository = ref.read(supabaseTaskRepositoryProvider);
      await repository.toggleTaskCompletion(taskId);

      // Invalidate related providers
      ref.invalidate(allTasksProvider);
      ref.invalidate(taskStatsProvider);
      ref.invalidate(taskByIdProvider(taskId));
      ref.invalidate(filteredTasksProvider);
      ref.invalidate(todaysTasksProvider);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling task: $e');
      }
      return false;
    }
  }

  /// Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      final repository = ref.read(supabaseTaskRepositoryProvider);
      await repository.deleteTask(taskId);

      // Invalidate related providers
      ref.invalidate(allTasksProvider);
      ref.invalidate(taskStatsProvider);
      ref.invalidate(filteredTasksProvider);
      ref.invalidate(todaysTasksProvider);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting task: $e');
      }
      return false;
    }
  }

  /// Refresh all tasks
  Future<void> refreshTasks() async {
    ref.invalidate(allTasksProvider);
    ref.invalidate(taskStatsProvider);
    ref.invalidate(filteredTasksProvider);
    ref.invalidate(todaysTasksProvider);
  }
}

/// Enum for task filtering
enum TaskFilter {
  all,
  pending,
  completed,
}

/// Statistics model for tasks
class TaskStats {
  final int total;
  final int completed;
  final int pending;
  final int highPriority;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.highPriority,
  });

  double get completionRate => total > 0 ? completed / total : 0.0;

  @override
  String toString() {
    return 'TaskStats(total: $total, completed: $completed, pending: $pending, highPriority: $highPriority)';
  }
}

/// Task Service provider
@riverpod
TaskService taskService(TaskServiceRef ref) {
  return TaskService(ref);
}

/// Task Notifier provider
@riverpod
TaskNotifier taskNotifier(AutoDisposeProviderRef<TaskNotifier> ref) {
  return TaskNotifier();
}
