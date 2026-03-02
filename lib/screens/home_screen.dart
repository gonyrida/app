import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;

import '../core/theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../features/task_management/presentation/widgets/task_card.dart';
import '../providers/user_session_provider.dart';
import '../widgets/search_bar.dart' as app_search;

/// HomeScreen - Dashboard with greeting, stats, and today's tasks
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskProvider = ref.watch(taskProviderProvider);
    final stats = ref.watch(taskStatsProvider);
    final todaysTasks = ref.watch(todaysTasksProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final userSession = provider.Provider.of<UserSessionProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            /// Header
            SliverToBoxAdapter(
              child: _buildHeader(context, userSession),
            ),

            /// Search Bar
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

            /// Stats
            SliverToBoxAdapter(
              child: _buildStatsCards(context, stats),
            ),

            /// Today's Tasks Header
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
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'See all',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Tasks List / States
            if (searchQuery.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildNoSearchResults(),
              ),
            ] else if (todaysTasks.isEmpty) ...[
              SliverToBoxAdapter(
                child: _buildEmptyState(),
              ),
            ] else ...[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = todaysTasks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: TaskCard(
                        task: task,
                        onToggle: () {
                          taskProvider.toggleTask(int.tryParse(task.id) ?? 0);
                        },
                      ),
                    );
                  },
                  childCount: todaysTasks.length,
                ),
              ),
            ],
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

  /// Header
  Widget _buildHeader(BuildContext context, UserSessionProvider userSession) {
    final now = DateTime.now();
    final greeting = _getGreeting(now);
    final dateStr = DateFormat('EEEE, MMM d').format(now);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, ${userSession.name ?? "User"}!',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Stats Section
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
        children: [
          Expanded(
            child: _buildStatItem('Total Tasks', stats.total.toString(),
                Icons.list_alt, Colors.white),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildStatItem('Completed', stats.completed.toString(),
                Icons.check_circle, Colors.greenAccent),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildStatItem('Pending', stats.pending.toString(),
                Icons.pending_actions, Colors.orangeAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color valueColor) {
    return Column(
      children: [
        Icon(icon, color: valueColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildStatDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.white24,
    );
  }

  /// Empty State
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks for today',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// No Search Results
  Widget _buildNoSearchResults() {
    return Padding(
      padding: const EdgeInsets.all(32),
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
