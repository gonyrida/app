import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/supabase_task_repository.dart';
import '../../../../data/models/supabase_task_model.dart';
import '../domain/models/task_model.dart';
import '../../../../core/services/supabase_service.dart';

/// Supabase Task Providers
/// Replace the existing Isar-based providers with Supabase equivalents

/// Repository provider
final supabaseTaskRepositoryProvider = Provider<SupabaseTaskRepository>((ref) {
  return SupabaseTaskRepository();
});

/// All tasks provider
final supabaseAllTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  final supabaseTasks = await repository.getAllTasks();
  return supabaseTasks.map((task) => task.toLocalModel()).toList();
});

/// Pending tasks provider
final supabasePendingTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  final supabaseTasks = await repository.getPendingTasks();
  return supabaseTasks.map((task) => task.toLocalModel()).toList();
});

/// Completed tasks provider
final supabaseCompletedTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  final supabaseTasks = await repository.getCompletedTasks();
  return supabaseTasks.map((task) => task.toLocalModel()).toList();
});

/// Tasks by priority provider
final supabaseTasksByPriorityProvider = FutureProvider.family<List<TaskModel>, String>((ref, priority) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  final supabaseTasks = await repository.getTasksByPriority(priority);
  return supabaseTasks.map((task) => task.toLocalModel()).toList();
});

/// Tasks by category provider
final supabaseTasksByCategoryProvider = FutureProvider.family<List<TaskModel>, String>((ref, category) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  final supabaseTasks = await repository.getTasksByCategory(category);
  return supabaseTasks.map((task) => task.toLocalModel()).toList();
});

/// Today's tasks provider
final supabaseTodayTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  final supabaseTasks = await repository.getTodayTasks();
  return supabaseTasks.map((task) => task.toLocalModel()).toList();
});

/// Tasks for month provider
final supabaseMonthlyTasksProvider = FutureProvider.family<List<TaskModel>, DateTime>((ref, date) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  final supabaseTasks = await repository.getTasksForMonth(date.year, date.month);
  return supabaseTasks.map((task) => task.toLocalModel()).toList();
});

/// Overdue tasks provider
final supabaseOverdueTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  final supabaseTasks = await repository.getOverdueTasks();
  return supabaseTasks.map((task) => task.toLocalModel()).toList();
});

/// Search tasks provider
final supabaseSearchTasksProvider = FutureProvider.family<List<TaskModel>, String>((ref, query) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  final supabaseTasks = await repository.searchTasks(query);
  return supabaseTasks.map((task) => task.toLocalModel()).toList();
});

/// Task statistics provider
final supabaseTaskStatsProvider = FutureProvider<TaskStats>((ref) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  return await repository.getTaskStats();
});

/// Real-time tasks stream provider
final supabaseTasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  return repository.watchAllTasks().map((supabaseTasks) => 
    supabaseTasks.map((task) => task.toLocalModel()).toList());
});

/// Real-time pending tasks stream provider
final supabasePendingTasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  return repository.watchTasksByCompletion(false).map((supabaseTasks) => 
    supabaseTasks.map((task) => task.toLocalModel()).toList());
});

/// Task service provider for CRUD operations
class SupabaseTaskService {
  final SupabaseTaskRepository _repository;

  SupabaseTaskService(this._repository);

  /// Add a new task
  Future<TaskModel> addTask(TaskModel task) async {
    final userId = SupabaseService.instance.currentUserId!;
    final supabaseTask = SupabaseTaskModel.fromLocalModel(task, userId);
    final createdTask = await _repository.addTask(supabaseTask);
    return createdTask.toLocalModel();
  }

  /// Update an existing task
  Future<TaskModel> updateTask(TaskModel task) async {
    final userId = SupabaseService.instance.currentUserId!;
    final supabaseTask = SupabaseTaskModel.fromLocalModel(task, userId);
    final updatedTask = await _repository.updateTask(supabaseTask);
    return updatedTask.toLocalModel();
  }

  /// Toggle task completion
  Future<TaskModel> toggleTaskCompletion(String taskId) async {
    final updatedTask = await _repository.toggleTaskCompletion(taskId);
    return updatedTask.toLocalModel();
  }

  /// Delete a task
  Future<bool> deleteTask(String taskId) async {
    return await _repository.deleteTask(taskId);
  }

  /// Delete multiple tasks
  Future<int> deleteTasks(List<String> taskIds) async {
    return await _repository.deleteTasks(taskIds);
  }

  /// Get task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    final task = await _repository.getTaskById(taskId);
    return task?.toLocalModel();
  }
}

/// Task service provider
final supabaseTaskServiceProvider = Provider<SupabaseTaskService>((ref) {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  return SupabaseTaskService(repository);
});
