import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_service.dart';
import '../../application/task_providers.dart' as task_providers;
import '../../application/supabase_task_providers.dart' as supabase_providers;
import '../widgets/task_card.dart';

// Import TaskStats from task_providers
import '../../application/task_providers.dart';

/// HomeScreen - Dashboard with greeting, stats, and today's tasks
///
/// Features:
/// - Good morning greeting + user name + date
/// - Stats cards: Total / Completed / Pending (blue/orange colors)
/// - Today's tasks section with ListView of task cards
/// - Floating blue + button to add task
/// - BottomNavigationBar with 4 items (Home active)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d');
    return formatter.format(now);
  }

  /// Convert Map<String, int> to TaskStats object
  TaskStats _convertMapToTaskStats(Map<String, int> statsMap) {
    return TaskStats(
      total: statsMap['total'] ?? 0,
      completed: statsMap['completed'] ?? 0,
      pending: statsMap['pending'] ?? 0,
      highPriority: statsMap['high_priority'] ?? 0,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasksAsync = ref.watch(task_providers.todaysTasksProvider);
    final statsAsync = ref.watch(supabase_providers.supabaseTaskStatsProvider);
    final taskService = ref.read(task_providers.taskServiceProvider);

    // Debug: Add logging to check authentication state
    final currentUserId = SupabaseService.instance.currentUserId;
    final isAuthenticated = SupabaseService.instance.isAuthenticated;

    // Force refresh stats if they seem to be missing
    if (statsAsync.hasValue &&
        (statsAsync.value?['total'] ?? 0) == 0 &&
        currentUserId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(supabase_providers.supabaseTaskStatsProvider);
      });
    }

    if (kDebugMode) {
      print('DEBUG HomeScreen: User ID: $currentUserId');
      print('DEBUG HomeScreen: Is Authenticated: $isAuthenticated');
      print('DEBUG HomeScreen: Stats state: ${statsAsync.value}');
      print('DEBUG HomeScreen: Stats loading: ${statsAsync.isLoading}');
      print('DEBUG HomeScreen: Stats error: ${statsAsync.error}');
      print(
          'DEBUG HomeScreen: Today tasks state: ${todayTasksAsync.value?.length} tasks');
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with Greeting
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "John Doe", // TODO: Get from user provider
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFormattedDate(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Debug info
                    if (kDebugMode) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isAuthenticated
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isAuthenticated ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Debug Info:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    isAuthenticated ? Colors.green : Colors.red,
                              ),
                            ),
                            Text(
                              'User ID: ${currentUserId ?? "Not logged in"}',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black87),
                            ),
                            Text(
                              'Auth Status: ${isAuthenticated ? "Authenticated" : "Not Authenticated"}',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black87),
                            ),
                            Text(
                              'Stats: ${statsAsync.value?['total'] ?? 0} total, ${statsAsync.value?['completed'] ?? 0} completed, ${statsAsync.value?['pending'] ?? 0} pending',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black87),
                            ),
                            Text(
                              'Stats Async State: ${statsAsync.isLoading ? "Loading" : statsAsync.hasError ? "Error: ${statsAsync.error}" : "Data"}',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black87),
                            ),
                            Text(
                              'Today Tasks: ${todayTasksAsync.value?.length ?? 0} tasks',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (statsMap) {
                  final stats = _convertMapToTaskStats(statsMap);
                  if (kDebugMode) {
                    print(
                        'DEBUG HomeScreen: Stats data received - Total: ${stats.total}, Completed: ${stats.completed}, Pending: ${stats.pending}');
                  }
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                            'Total', stats.total.toString(), Icons.list_alt),
                        _buildStatDivider(),
                        _buildStatItem('Completed', stats.completed.toString(),
                            Icons.check_circle),
                        _buildStatDivider(),
                        _buildStatItem('Pending', stats.pending.toString(),
                            Icons.pending_actions),
                      ],
                    ),
                  );
                },
                loading: () {
                  if (kDebugMode) {
                    print('DEBUG HomeScreen: Stats loading...');
                  }
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                },
                error: (error, stack) {
                  if (kDebugMode) {
                    print('DEBUG HomeScreen: Stats error: $error');
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Today's Tasks Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Tasks",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/list'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Today's Tasks List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: todayTasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 32),
                            Icon(
                              Icons.task_alt,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks for today',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enjoy your free time!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onToggle: () {
                            taskService.toggleTaskCompletion(task.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  task.isCompleted
                                      ? 'Task marked as pending'
                                      : 'Task marked as complete',
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: tasks.length,
                    ),
                  );
                },
                loading: () => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const TaskCardSkeleton(),
                    childCount: 3,
                  ),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(height: 8),
                        Text('Error: $error'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-task'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.white24,
    );
  }
}

/// TaskCardSkeleton - Loading placeholder
class TaskCardSkeleton extends StatelessWidget {
  const TaskCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
