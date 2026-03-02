import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/task_model.dart';

/// SupabaseTaskRepository - Repository for task management using Supabase
class SupabaseTaskRepository {
  final SupabaseClient _client = SupabaseService.instance.client;
  static const String _tableName = 'tasks';

  /// Get all tasks for the current user
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => TaskModel.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  /// Get task by ID
  Future<TaskModel?> getTaskById(String id) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return TaskModel.fromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch task: $e');
    }
  }

  /// Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final taskData = task.toSupabaseMap();
      taskData['user_id'] = userId;
      taskData.remove('id'); // Let Supabase generate UUID

      // Upload image to Supabase Storage if exists
      if (task.imagePath != null && task.imagePath!.isNotEmpty) {
        try {
          final imageFile = File(task.imagePath!);
          final fileName = 'task_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = 'users/$userId/tasks/$fileName';

          // Upload file to storage
          await SupabaseService.instance.uploadFile(
            bucket: 'task-images',
            path: filePath,
            file: imageFile,
          );

          // Get public URL
          final publicUrl = SupabaseService.instance.getPublicUrl(
            bucket: 'task-images',
            path: filePath,
          );

          taskData['image_url'] = publicUrl;
        } catch (imageError) {
          if (kDebugMode) {
            print('Error uploading image: $imageError');
          }
          // Continue without image if upload fails
          taskData['image_url'] = null;
        }
      } else {
        taskData['image_url'] = null;
      }

      final response =
          await _client.from(_tableName).insert(taskData).select().single();

      return TaskModel.fromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  /// Update an existing task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final taskData = task.toSupabaseMap();
      taskData.remove('user_id'); // Don't update user_id

      // Upload image to Supabase Storage if exists
      if (task.imagePath != null && task.imagePath!.isNotEmpty) {
        try {
          final imageFile = File(task.imagePath!);
          final fileName = 'task_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = 'users/$userId/tasks/$fileName';

          // Upload file to storage
          await SupabaseService.instance.uploadFile(
            bucket: 'task-images',
            path: filePath,
            file: imageFile,
          );

          // Get public URL
          final publicUrl = SupabaseService.instance.getPublicUrl(
            bucket: 'task-images',
            path: filePath,
          );

          taskData['image_url'] = publicUrl;
        } catch (imageError) {
          if (kDebugMode) {
            print('Error uploading image: $imageError');
          }
          // Continue without image if upload fails
          taskData['image_url'] = null;
        }
      } else {
        taskData['image_url'] = null;
      }

      final response = await _client
          .from(_tableName)
          .update(taskData)
          .eq('id', task.id)
          .eq('user_id', userId)
          .select()
          .single();

      return TaskModel.fromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Toggle task completion status
  Future<TaskModel> toggleTaskCompletion(String id) async {
    try {
      final task = await getTaskById(id);
      if (task == null) {
        throw Exception('Task not found');
      }

      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
      );

      return await updateTask(updatedTask);
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }

  /// Get tasks filtered by completion status
  Future<List<TaskModel>> getTasksByStatus({required bool isCompleted}) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_completed', isCompleted)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => TaskModel.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks by status: $e');
    }
  }

  /// Get tasks filtered by priority
  Future<List<TaskModel>> getTasksByPriority(String priority) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('priority', priority)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => TaskModel.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks by priority: $e');
    }
  }

  /// Get tasks filtered by category
  Future<List<TaskModel>> getTasksByCategory(String category) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => TaskModel.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks by category: $e');
    }
  }

  /// Search tasks by title or description
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => TaskModel.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search tasks: $e');
    }
  }

  /// Get task statistics
  Future<Map<String, int>> getTaskStats() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('task_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return {
          'total': 0,
          'completed': 0,
          'pending': 0,
          'high_priority': 0,
          'overdue': 0,
        };
      }

      return {
        'total': response['total'] as int? ?? 0,
        'completed': response['completed'] as int? ?? 0,
        'pending': response['pending'] as int? ?? 0,
        'high_priority': response['high_priority'] as int? ?? 0,
        'overdue': response['overdue'] as int? ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch task stats: $e');
    }
  }
}
