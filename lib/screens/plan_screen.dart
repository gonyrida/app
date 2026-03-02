import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/theme/app_theme.dart';
import '../features/task_management/application/supabase_task_providers.dart';
import '../features/task_management/domain/models/task_model.dart';
import '../features/task_management/presentation/widgets/priority_chip.dart';

/// PlanScreen - Calendar view with task timeline
///
/// Features:
/// - Monthly view (table_calendar)
/// - Highlight dates with task count badge
/// - Timeline/day view with hourly slots showing tasks
/// - Colored by priority (orange/yellow/red blocks)
/// - Add new task button
/// - Bottom nav Plan active
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final allTasksAsync = ref.watch(supabaseTaskListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Plan',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: allTasksAsync.when(
        data: (tasks) {
          return Column(
            children: [
              // Calendar
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    // Navigate to add task with selected date
                    final dateStr = selectedDay.toIso8601String();
                    context.push('/add-task?date=$dateStr');
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: GoogleFonts.inter(color: Colors.red),
                    holidayTextStyle: GoogleFonts.inter(color: Colors.red),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    markerDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: true,
                    formatButtonDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    formatButtonTextStyle: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    titleTextStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: const Icon(Icons.chevron_left,
                        color: AppColors.primary),
                    rightChevronIcon: const Icon(Icons.chevron_right,
                        color: AppColors.primary),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    weekendStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final dayTasks = _getTasksForDay(tasks, date);
                      if (dayTasks.isEmpty) return null;

                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getPriorityColorForDay(dayTasks),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      final dayTasks = _getTasksForDay(tasks, day);
                      if (dayTasks.isNotEmpty) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getPriorityColorForDay(dayTasks)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),

              // Selected Day Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDay != null
                          ? DateFormat('EEEE, MMMM d').format(_selectedDay!)
                          : 'Select a date',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_getTasksForDay(tasks, _selectedDay).length} tasks',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Timeline for selected day
              Expanded(
                child: _buildTimeline(tasks),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Failed to load calendar',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Pre-fill due date with selected day
          final dateStr = _selectedDay?.toIso8601String();
          if (dateStr != null) {
            context.push('/add-task?date=$dateStr');
          } else {
            context.push('/add-task');
          }
        },
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

  /// Get tasks for a specific day
  List<TaskModel> _getTasksForDay(List<TaskModel> tasks, DateTime? day) {
    if (day == null) return [];

    return tasks.where((task) {
      // Include tasks due on this specific day OR created on this day (for tasks without due dates)
      if (task.dueDate != null) {
        return isSameDay(task.dueDate!, day);
      } else {
        // For tasks without due dates, check if they were created on this day
        return isSameDay(task.createdAt, day);
      }
    }).toList();
  }

  /// Get priority color for day (highest priority)
  Color _getPriorityColorForDay(List<TaskModel> tasks) {
    if (tasks.any((t) => t.priority == Priority.high && !t.isCompleted)) {
      return const Color(0xFFF44336); // Red
    }
    if (tasks.any((t) => t.priority == Priority.medium && !t.isCompleted)) {
      return const Color(0xFFFF9800); // Orange
    }
    return const Color(0xFFFFC107); // Yellow
  }

  /// Build timeline for selected day
  Widget _buildTimeline(List<TaskModel> allTasks) {
    final dayTasks = _getTasksForDay(allTasks, _selectedDay);

    if (dayTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks for this day',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new task',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Sort by time
    dayTasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dayTasks.length,
      itemBuilder: (context, index) {
        final task = dayTasks[index];
        return _buildTimelineItem(task, index == dayTasks.length - 1);
      },
    );
  }

  /// Build timeline item
  Widget _buildTimelineItem(TaskModel task, bool isLast) {
    final priorityColor = _getTaskPriorityColor(task.priority);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  task.dueDate != null
                      ? DateFormat('h:mm a').format(task.dueDate!)
                      : 'All day',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Timeline line
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: priorityColor.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Task card
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.push('/task-detail/${task.id}', extra: task);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(
                      color: priorityColor,
                      width: 4,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted
                                  ? Colors.grey
                                  : AppColors.textPrimary,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (task.isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PriorityChip(
                          priority: task.priority,
                          compact: true,
                          showLabel: false,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.category,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        task.description!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get color for priority
  Color _getTaskPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return const Color(0xFFF44336); // Red
      case Priority.medium:
        return const Color(0xFFFF9800); // Orange
      case Priority.low:
        return const Color(0xFFFFC107); // Yellow
    }
  }
}
