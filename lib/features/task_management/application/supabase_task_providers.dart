import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/supabase_task_repository.dart';
import '../domain/models/task_model.dart';

/// Supabase Task Providers
/// Handles all task-related operations with Supabase

/// Repository provider
final supabaseTaskRepositoryProvider = Provider<SupabaseTaskRepository>((ref) {
  return SupabaseTaskRepository();
});

/// Task list provider for current user
final supabaseTaskListProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  final supabaseTasks = await repository.getAllTasks();
  return supabaseTasks;
});

/// Task statistics provider
final supabaseTaskStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.read(supabaseTaskRepositoryProvider);
  return await repository.getTaskStats();
});
