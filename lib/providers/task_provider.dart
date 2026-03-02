import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../data/sample_tasks.dart';

enum FilterType { all, pending, completed }

// Riverpod provider for TaskProvider
final taskProviderProvider =
    ChangeNotifierProvider<TaskProvider>((ref) => TaskProvider());

// Additional providers for convenience
final allTasksProvider = Provider<List<TaskModel>>((ref) {
  return ref.watch(taskProviderProvider).tasks;
});

final todaysTasksProvider = Provider<List<TaskModel>>((ref) {
  return ref.watch(taskProviderProvider).tasks;
});

final taskStatsProvider = Provider<TaskStats>((ref) {
  final provider = ref.watch(taskProviderProvider);
  return TaskStats(
    total: provider.totalTasks,
    completed: provider.completedTasks,
    pending: provider.pendingTasks,
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');

class TaskStats {
  final int total;
  final int completed;
  final int pending;

  TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
  });
}

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  String _query = '';
  FilterType _filter = FilterType.all;
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  String get query => _query;
  FilterType get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      if (_filter == FilterType.pending && task.isCompleted) return false;
      if (_filter == FilterType.completed && !task.isCompleted) return false;
      if (_query.isNotEmpty &&
          !task.title.toLowerCase().contains(_query.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  TaskProvider() {
    _tasks = [];
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(FilterType value) {
    _filter = value;
    notifyListeners();
  }

  void toggleTask(int id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].toggleComplete();
      notifyListeners();
    }
  }

  Future<bool> addTask(TaskModel task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _tasks.add(task);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _tasks.removeWhere((task) => task.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tasks = await ApiAdapter.fetchTasks();
      _tasks = tasks;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // If fetch fails, keep current tasks or empty list
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _filter = FilterType.all;
    notifyListeners();
  }

  int get totalTasks => _tasks.length;

  int get completedTasks => _tasks.where((task) => task.isCompleted).length;

  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;

  int get highPriorityTasks => _tasks
      .where((task) => task.priority == Priority.high && !task.isCompleted)
      .length;
}
