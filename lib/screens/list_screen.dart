import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import '../features/task_management/application/task_providers.dart';
import '../features/task_management/domain/models/task_model.dart';
import '../features/task_management/presentation/widgets/task_card.dart';
import '../widgets/search_bar.dart' as app_search;

// Providers for search and filter state
final selectedFilterProvider =
    StateProvider<TaskFilter>((ref) => TaskFilter.all);
final searchQueryProvider = StateProvider<String>((ref) => '');

/// ListScreen - Task list with search and filter tabs
///
/// Features:
/// - Search bar at top
/// - Tabs: All | Pending | Completed
/// - List of task cards from Isar
/// - Card design: priority border color, checkbox toggle, title, due, image, category
/// - On tap → navigate to details
/// - Bottom nav List active
class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final filter = TaskFilter.values[_tabController.index];
      ref.read(selectedFilterProvider.notifier).state = filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);

    // Sync tab controller with provider state
    if (_tabController.index != selectedFilter.index) {
      _tabController.animateTo(selectedFilter.index);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Tasks',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
            onPressed: () {
              // TODO: Show advanced filter bottom sheet
              _showFilterBottomSheet(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: app_search.SearchBarWidget(
              value: searchQuery,
              onChangeText: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              placeholder: 'Search tasks by title, description...',
            ),
          ),

          // Task List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Tasks Tab
                _buildTaskList(TaskFilter.all, searchQuery),

                // Pending Tasks Tab
                _buildTaskList(TaskFilter.pending, searchQuery),

                // Completed Tasks Tab
                _buildTaskList(TaskFilter.completed, searchQuery),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-task'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Build task list for a specific filter
  Widget _buildTaskList(TaskFilter filter, String searchQuery) {
    final tasksAsync = ref.watch(filteredTasksProvider(
      filter: filter,
      searchQuery: searchQuery,
    ));

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyState(filter, searchQuery.isNotEmpty);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCard(
                task: task,
                onToggle: () => _toggleTask(task),
                onTap: () {
                  context.push('/task-detail/${task.id}', extra: task);
                },
              ),
            );
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: TaskCardSkeleton(),
        ),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  /// Toggle task completion
  Future<void> _toggleTask(TaskModel task) async {
    final taskService = ref.read(taskServiceProvider);
    final success = await taskService.toggleTaskCompletion(task.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            task.isCompleted ? 'Task marked as pending' : 'Task completed!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.white,
            onPressed: () async {
              await ref.read(taskServiceProvider).toggleTaskCompletion(task.id);
            },
          ),
        ),
      );
    }
  }

  /// Build empty state
  Widget _buildEmptyState(TaskFilter filter, bool hasSearch) {
    String message;
    IconData icon;

    if (hasSearch) {
      message = 'No tasks match your search';
      icon = Icons.search_off;
    } else {
      switch (filter) {
        case TaskFilter.pending:
          message = 'No pending tasks!\nYou\'re all caught up.';
          icon = Icons.check_circle_outline;
          break;
        case TaskFilter.completed:
          message = 'No completed tasks yet.\nStart completing some tasks!';
          icon = Icons.task_alt;
          break;
        case TaskFilter.all:
        default:
          message = 'No tasks yet.\nAdd your first task to get started!';
          icon = Icons.add_task;
          break;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (!hasSearch && filter == TaskFilter.all) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/add-task'),
              icon: const Icon(Icons.add),
              label: const Text('Add First Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load tasks',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(filteredTasksProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Filter & Sort',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sort),
                title: Text('Sort by Priority', style: GoogleFonts.inter()),
                trailing: const Icon(Icons.check, color: AppColors.primary),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('Sort by Due Date', style: GoogleFonts.inter()),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: Text('Filter by Category', style: GoogleFonts.inter()),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
