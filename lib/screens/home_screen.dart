import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;

import '../core/theme/app_theme.dart';
import '../features/task_management/application/task_providers.dart';
import '../features/task_management/presentation/widgets/task_card.dart';
import '../providers/user_session_provider.dart';
import '../widgets/search_bar.dart' as app_search;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(taskStatsProvider);
    final todaysTasksAsync = ref.watch(todaysTasksProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final userSession = provider.Provider.of<UserSessionProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: _buildHeader(context, userSession),
            ),

            // Stats Cards Section
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => _buildStatsCards(context, stats),
                loading: () => _buildStatsSkeleton(),
                error: (error, stack) => _buildStatsError(error.toString()),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: app_search.SearchBarWidget(
                  value: searchQuery,
                  onChangeText: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  placeholder: 'Search tasks...',
                ),
              ),
            ),

            // Today's Tasks Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Tasks",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/list'),
                      child: Text(
                        'See All',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Today's Tasks List
            todaysTasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmptyState(),
                  );
                }

                // Filter by search query if provided
                final filteredTasks = searchQuery.isEmpty
                    ? tasks
                    : tasks.where((task) {
                        return task.title
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()) ||
                            (task.description
                                    ?.toLowerCase()
                                    .contains(searchQuery.toLowerCase()) ??
                                false);
                      }).toList();

                if (filteredTasks.isEmpty && searchQuery.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildNoSearchResults(),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = filteredTasks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: TaskCard(
                          task: task,
                          onToggle: () async {
                            final success = await ref
                                .read(taskNotifierProvider.notifier)
                                .toggleTaskCompletion(task.id);

                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    task.isCompleted
                                        ? 'Task marked as pending'
                                        : 'Task completed!',
                                    style: GoogleFonts.inter(),
                                  ),
                                  backgroundColor: task.isCompleted
                                      ? Colors.orange
                                      : Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          onTap: () {
                            context.push('/task-detail/${task.id}',
                                extra: task);
                          },
                        ),
                      );
                    },
                    childCount: filteredTasks.length,
                  ),
                );
              },
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: TaskCardSkeleton(),
                  ),
                  childCount: 3,
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: _buildErrorState(error.toString()),
              ),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-task'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Task',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build header with greeting and date
  Widget _buildHeader(BuildContext context, UserSessionProvider userSession) {
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    // Use stored name or extract from email, or default to 'User'
    String displayName = 'User';
    if (userSession.name?.isNotEmpty == true) {
      displayName = userSession.name!;
    } else if (userSession.email?.isNotEmpty == true) {
      // Extract name from email as fallback
      final emailPrefix = userSession.email!.split('@')[0];
      displayName = emailPrefix
          .replaceAll(RegExp(r'[._-]'), ' ')
          .split(' ')
          .map((word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '')
          .join(' ');
    }

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (userSession.phone?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      userSession.phone!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(now),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build stats cards (Total / Completed / Pending)
  Widget _buildStatsCards(BuildContext context, TaskStats stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total',
            stats.total.toString(),
            Icons.list_alt,
            Colors.white,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Completed',
            stats.completed.toString(),
            Icons.check_circle,
            Colors.greenAccent,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Pending',
            stats.pending.toString(),
            Icons.pending_actions,
            Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color valueColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// Build divider between stats
  Widget _buildStatDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.white24,
    );
  }

  /// Build skeleton loading for stats
  Widget _buildStatsSkeleton() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  /// Build error state for stats
  Widget _buildStatsError(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load stats: $error',
              style: GoogleFonts.inter(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state when no tasks
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks for today!',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy your free time or add a new task',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build no search results state
  Widget _buildNoSearchResults() {
    return Container(
      margin: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error: $error',
              style: GoogleFonts.inter(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
