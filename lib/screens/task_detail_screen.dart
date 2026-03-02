import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../features/task_management/application/task_providers.dart';
import '../features/task_management/domain/models/task_model.dart';
import '../features/task_management/presentation/widgets/priority_chip.dart';

/// TaskDetailScreen - View task details with actions
///
/// Features:
/// - Big title
/// - Status (In Process / Completed)
/// - Description
/// - Deadline & priority colored tag
/// - Subtasks checklist (with progress)
/// - Image display if exists
/// - Buttons: Mark Complete (toggle), Delete (confirm dialog)
/// - Edit icon top right → navigate to edit
/// - Hero animation for smooth image transition
class TaskDetailScreen extends ConsumerWidget {
  final TaskModel task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the task for real-time updates
    final taskAsync = ref.watch(taskByIdProvider(task.id));

    return taskAsync.when(
      data: (updatedTask) {
        final displayTask = updatedTask ?? task;
        return _buildContent(context, ref, displayTask);
      },
      loading: () => _buildContent(context, ref, task),
      error: (_, __) => _buildContent(context, ref, task),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, TaskModel displayTask) {
    final subtaskProgress = displayTask.subtasks.isEmpty
        ? displayTask.isCompleted
            ? 1.0
            : 0.0
        : displayTask.isCompleted
            ? 1.0
            : 0.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: displayTask.imagePath != null ? 300 : 120,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () {
                  context.push('/edit-task/${displayTask.id}',
                      extra: displayTask);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(context, ref, displayTask),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: displayTask.imagePath != null
                  ? Hero(
                      tag: 'task_image_${displayTask.id}',
                      child: Image.file(
                        File(displayTask.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade500,
                              size: 48,
                            ),
                          );
                        },
                      ),
                    )
                  : null,
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: displayTask.isCompleted
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              displayTask.isCompleted
                                  ? Icons.check_circle
                                  : Icons.timelapse,
                              color: displayTask.isCompleted
                                  ? Colors.green
                                  : Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              displayTask.isCompleted
                                  ? 'Completed'
                                  : 'In Progress',
                              style: GoogleFonts.inter(
                                color: displayTask.isCompleted
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      PriorityChip(
                        priority: displayTask.priority,
                        isOutlined: displayTask.priority == Priority.low,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    displayTask.title,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      decoration: displayTask.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      displayTask.category,
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Due Date',
                          displayTask.dueDate != null
                              ? DateFormat('MMM d, yyyy')
                                  .format(displayTask.dueDate!)
                              : 'No due date',
                          Icons.calendar_today,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Due Time',
                          displayTask.dueDate != null
                              ? DateFormat('h:mm a')
                                  .format(displayTask.dueDate!)
                              : 'No time set',
                          Icons.access_time,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (displayTask.description != null &&
                      displayTask.description!.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        displayTask.description!,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Subtasks
                  if (displayTask.subtasks.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtasks',
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
                            '${(subtaskProgress * displayTask.subtasks.length).toInt()}/${displayTask.subtasks.length}',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: subtaskProgress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    ...displayTask.subtasks.asMap().entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              displayTask.isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: displayTask.isCompleted
                                  ? Colors.green
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  decoration: displayTask.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: displayTask.isCompleted
                                      ? Colors.grey
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Created/Updated Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Info',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${DateFormat('MMM d, yyyy • h:mm a').format(displayTask.createdAt)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Updated: ${DateFormat('MMM d, yyyy • h:mm a').format(displayTask.updatedAt)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _toggleTaskCompletion(context, ref, displayTask),
              icon: Icon(
                displayTask.isCompleted ? Icons.refresh : Icons.check_circle,
                color: Colors.white,
              ),
              label: Text(
                displayTask.isCompleted
                    ? 'Mark as Pending'
                    : 'Mark as Complete',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    displayTask.isCompleted ? Colors.orange : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build info card
  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle task completion
  Future<void> _toggleTaskCompletion(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
  ) async {
    final taskService = ref.read(taskServiceProvider);
    final success = await taskService.toggleTaskCompletion(task.id);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            task.isCompleted ? 'Task marked as pending' : 'Task completed!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Confirm delete
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Task?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final taskService = ref.read(taskServiceProvider);
      final success = await taskService.deleteTask(task.id);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task deleted successfully',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    }
  }
}
