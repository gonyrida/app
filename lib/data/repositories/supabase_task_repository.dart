import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/supabase_task_model.dart';
import '../../features/task_management/domain/models/task_model.dart';

/// Supabase Task Repository
/// Handles all task-related database operations with Supabase
class SupabaseTaskRepository {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Get all tasks for current user
  Future<List<SupabaseTaskModel>> getAllTasks() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((task) => SupabaseTaskModel.fromMap(task)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all tasks: $e');
      }
      return [];
    }
  }

  /// Get tasks by completion status
  Future<List<SupabaseTaskModel>> getTasksByCompletion(bool isCompleted) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', isCompleted)
          .order('created_at', ascending: false);

      debugPrint('Supabase response: $response');
      debugPrint('Response type: ${response.runtimeType}');
      
      if (response is List) {
        debugPrint('Response length: ${response.length}');
        for (int i = 0; i < response.length; i++) {
          debugPrint('Task $i: ${response[i]}');
        }
      }

      return response.map((task) => SupabaseTaskModel.fromMap(task)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks by completion: $e');
      }
      return [];
    }
  }

  /// Get pending tasks
  Future<List<SupabaseTaskModel>> getPendingTasks() async {
    return await getTasksByCompletion(false);
  }

  /// Get completed tasks
  Future<List<SupabaseTaskModel>> getCompletedTasks() async {
    return await getTasksByCompletion(true);
  }

  /// Get tasks by priority
  Future<List<SupabaseTaskModel>> getTasksByPriority(String priority) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .eq('priority', priority)
          .order('created_at', ascending: false);

      return response.map((task) => SupabaseTaskModel.fromMap(task)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks by priority: $e');
      }
      return [];
    }
  }

  /// Get tasks by category
  Future<List<SupabaseTaskModel>> getTasksByCategory(String category) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .eq('category', category)
          .order('created_at', ascending: false);

      return response.map((task) => SupabaseTaskModel.fromMap(task)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks by category: $e');
      }
      return [];
    }
  }

  /// Get tasks by date
  Future<List<SupabaseTaskModel>> getTasksByDate(DateTime date) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .or('due_date.gte.${startOfDay.toIso8601String()}&due_date.lte.${endOfDay.toIso8601String()}|created_at.gte.${DateTime(date.year, date.month, 1).toIso8601String()}&created_at.lte.${DateTime(date.year, date.month + 1, 0).subtract(const Duration(days: 1)).toIso8601String()}')
          .order('due_date', ascending: true)
          .order('created_at', ascending: false);

      return response.map((task) => SupabaseTaskModel.fromMap(task)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks by date: $e');
      }
      return [];
    }
  }

  /// Get tasks for a month
  Future<List<SupabaseTaskModel>> getTasksForMonth(int year, int month) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0).subtract(const Duration(days: 1));

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .or('due_date.gte.${startOfMonth.toIso8601String()}&due_date.lte.${endOfMonth.toIso8601String()}|created_at.gte.${startOfMonth.toIso8601String()}&created_at.lte.${endOfMonth.toIso8601String()}')
          .order('due_date', ascending: true)
          .order('created_at', ascending: false);

      return response.map((task) => SupabaseTaskModel.fromMap(task)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks for month: $e');
      }
      return [];
    }
  }

  /// Get tasks by date range
  Future<List<SupabaseTaskModel>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .gte('due_date', startDate.toIso8601String())
          .lte('due_date', endDate.toIso8601String())
          .order('created_at', ascending: false);

      return response.map((task) => SupabaseTaskModel.fromMap(task)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks by date range: $e');
      }
      return [];
    }
  }

  /// Get overdue tasks
  Future<List<SupabaseTaskModel>> getOverdueTasks() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .lt('due_date', DateTime.now().toIso8601String())
          .eq('is_completed', false)
          .order('due_date', ascending: true);

      return response.map((task) => SupabaseTaskModel.fromMap(task)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting overdue tasks: $e');
      }
      return [];
    }
  }

  /// Get today's tasks
  Future<List<SupabaseTaskModel>> getTodayTasks() async {
    return await getTasksByDate(DateTime.now());
  }

  /// Search tasks
  Future<List<SupabaseTaskModel>> searchTasks(String query) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      if (query.isEmpty) return await getAllTasks();

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map((task) => SupabaseTaskModel.fromMap(task)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching tasks: $e');
      }
      return [];
    }
  }

  /// Get task by ID
  Future<SupabaseTaskModel?> getTaskById(String id) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('tasks')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .single();

      return SupabaseTaskModel.fromMap(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting task by ID: $e');
      }
      return null;
    }
  }

  /// Add new task
  Future<SupabaseTaskModel> addTask(SupabaseTaskModel task) async {
    try {
      final response = await _client
          .from('tasks')
          .insert(task.toMap())
          .select()
          .single();

      if (kDebugMode) {
        print('Task added successfully: ${response['id']}');
      }

      return SupabaseTaskModel.fromMap(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding task: $e');
      }
      rethrow;
    }
  }

  /// Update task
  Future<SupabaseTaskModel> updateTask(SupabaseTaskModel task) async {
    try {
      final response = await _client
          .from('tasks')
          .update(task.toMap())
          .eq('id', task.id)
          .select()
          .single();

      if (kDebugMode) {
        print('Task updated successfully: ${response['id']}');
      }

      return SupabaseTaskModel.fromMap(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating task: $e');
      }
      rethrow;
    }
  }

  /// Toggle task completion
  Future<SupabaseTaskModel> toggleTaskCompletion(String id) async {
    try {
      final task = await getTaskById(id);
      if (task == null) throw Exception('Task not found');

      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      return await updateTask(updatedTask);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling task completion: $e');
      }
      rethrow;
    }
  }

  /// Delete task
  Future<bool> deleteTask(String id) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('tasks')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Task deleted successfully: $id');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting task: $e');
      }
      return false;
    }
  }

  /// Delete multiple tasks
  Future<int> deleteTasks(List<String> ids) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('tasks')
          .delete()
          .inFilter('id', ids)
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Tasks deleted successfully: ${ids.length} tasks');
      }

      return ids.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting tasks: $e');
      }
      return 0;
    }
  }

  /// Get task statistics
  Future<TaskStats> getTaskStats() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('task_stats')
          .select()
          .eq('user_id', userId)
          .single();

      return TaskStats(
        total: response['total'] as int? ?? 0,
        completed: response['completed'] as int? ?? 0,
        pending: response['pending'] as int? ?? 0,
        highPriority: response['high_priority'] as int? ?? 0,
        overdue: response['overdue'] as int? ?? 0,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting task stats: $e');
      }
      return TaskStats(
        total: 0,
        completed: 0,
        pending: 0,
        highPriority: 0,
        overdue: 0,
      );
    }
  }

  /// Stream all tasks for real-time updates
  Stream<List<SupabaseTaskModel>> watchAllTasks() {
    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) return Stream.value([]);

    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((task) => SupabaseTaskModel.fromMap(task)).toList());
  }

  /// Stream tasks by completion status
  Stream<List<SupabaseTaskModel>> watchTasksByCompletion(bool isCompleted) {
    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) return Stream.value([]);

    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data
            .where((task) => task['is_completed'] == isCompleted)
            .map((task) => SupabaseTaskModel.fromMap(task))
            .toList());
  }

  /// Clear all tasks for user
  Future<void> clearAllTasks() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('tasks').delete().eq('user_id', userId);

      if (kDebugMode) {
        print('All tasks cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all tasks: $e');
      }
      rethrow;
    }
  }
}

/// Task statistics class (same as local repository)
class TaskStats {
  final int total;
  final int completed;
  final int pending;
  final int highPriority;
  final int overdue;

  TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.highPriority,
    required this.overdue,
  });

  double get completionRate => total > 0 ? completed / total : 0.0;

  @override
  String toString() {
    return 'TaskStats(total: $total, completed: $completed, pending: $pending)';
  }
}
