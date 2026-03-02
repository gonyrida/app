import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart' as provider;

import '../core/theme/app_theme.dart';
import '../core/services/supabase_service.dart';
import '../features/task_management/application/task_providers.dart';
import '../features/task_management/domain/models/task_model.dart';
import '../features/task_management/presentation/widgets/priority_chip.dart';
import '../providers/user_session_provider.dart';

/// AddTaskScreen - Create or edit a task
class AddTaskScreen extends StatefulWidget {
  final TaskModel? taskToEdit;
  final DateTime? preselectedDate;

  const AddTaskScreen({
    super.key,
    this.taskToEdit,
    this.preselectedDate,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subtaskController = TextEditingController();

  Priority _selectedPriority = Priority.medium;
  String _selectedCategory = 'Personal';
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String? _imagePath;
  final List<String> _subtasks = [];

  bool get _isEditing => widget.taskToEdit != null;

  final List<String> _categories = ['Work', 'Personal', 'Urgent', 'School'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _prefillForm();
    } else if (widget.preselectedDate != null) {
      _dueDate = widget.preselectedDate;
    }
  }

  void _prefillForm() {
    final task = widget.taskToEdit!;
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _selectedPriority = task.priority;
    _selectedCategory = task.category;
    _dueDate = task.dueDate;
    if (task.dueDate != null) {
      _dueTime = TimeOfDay.fromDateTime(task.dueDate!);
    }
    _imagePath = task.imagePath;
    _subtasks.addAll(task.subtasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (mounted) {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'Add New Task',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            Consumer(
              builder: (context, ref, child) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref),
                );
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            _buildSectionTitle('Task Title *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter task title',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: GoogleFonts.inter(fontSize: 16),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Description Field
            _buildSectionTitle('Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter task description (optional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: GoogleFonts.inter(fontSize: 16),
            ),

            const SizedBox(height: 24),

            // Due Date & Time
            _buildSectionTitle('Due Date & Time'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Priority Selector
            _buildSectionTitle('Priority'),
            const SizedBox(height: 8),
            PrioritySelector(
              selectedPriority: _selectedPriority,
              onPriorityChanged: (priority) {
                setState(() {
                  _selectedPriority = priority;
                });
              },
            ),

            const SizedBox(height: 24),

            // Category Selector
            _buildSectionTitle('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.inter(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Image Upload
            _buildSectionTitle('Task Image'),
            const SizedBox(height: 8),
            _buildImagePicker(),

            const SizedBox(height: 24),

            // Subtasks
            _buildSectionTitle('Subtasks'),
            const SizedBox(height: 8),
            _buildSubtasksList(),

            const SizedBox(height: 32),

            // Save Button
            Consumer(
              builder: (context, ref, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _saveTask(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isEditing ? 'Update Task' : 'Save Task',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Build date picker button
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _dueDate != null ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dueDate != null
                    ? DateFormat('MMM d, yyyy').format(_dueDate!)
                    : 'Select Date',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _dueDate != null ? AppColors.textPrimary : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build time picker button
  Widget _buildTimePicker() {
    final timeString = _formatTime(_dueTime);
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: _dueTime != null ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                timeString,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _dueTime != null ? AppColors.textPrimary : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build image picker
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imagePath != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _imagePath = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _imagePath != null ? 'Change Image' : 'Add Image',
                  style: GoogleFonts.inter(),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build subtasks list
  Widget _buildSubtasksList() {
    return Column(
      children: [
        // Existing subtasks
        ..._subtasks.asMap().entries.map((entry) {
          final index = entry.key;
          final subtask = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subtask,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _subtasks.removeAt(index);
                    });
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ],
            ),
          );
        }),

        // Add subtask input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _subtaskController,
                  decoration: InputDecoration(
                    hintText: 'Add a subtask',
                    hintStyle: GoogleFonts.inter(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  style: GoogleFonts.inter(fontSize: 14),
                  onSubmitted: _addSubtask,
                ),
              ),
              TextButton(
                onPressed: () => _addSubtask(_subtaskController.text),
                child: Text(
                  'Add',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Pick date
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  /// Pick time
  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _dueTime = time;
      });
    }
  }

  /// Pick image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Copy to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'task_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName');

      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  /// Add subtask
  void _addSubtask(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _subtasks.add(value.trim());
        _subtaskController.clear();
      });
    }
  }

  /// Save task
  Future<void> _saveTask(BuildContext context, WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) {
      print('FORM VALIDATION FAILED');
      return;
    }

    // Check if user is authenticated
    if (!SupabaseService.instance.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please sign in to create tasks',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        // Navigate to login screen
        context.go('/login');
      }
      return;
    }

    print('SAVING TASK: Starting save process...');

    try {
      // Combine date and time
      DateTime? finalDueDate;
      if (_dueDate != null) {
        finalDueDate = _dueDate;
        if (_dueTime != null) {
          finalDueDate = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            _dueTime!.hour,
            _dueTime!.minute,
          );
        }
      }

      print('SAVING TASK: Creating task object...');
      print('  Title: ${_titleController.text.trim()}');
      print('  Category: $_selectedCategory');
      print('  Priority: $_selectedPriority');

      // Get current user ID
      final sessionProvider =
          provider.Provider.of<UserSessionProvider>(context, listen: false);
      final userId = sessionProvider.email ?? '';

      final task = _isEditing
          ? widget.taskToEdit!.copyWith(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              priority: _selectedPriority,
              category: _selectedCategory,
              dueDate: finalDueDate,
              imagePath: _imagePath,
              subtasks: List.from(_subtasks),
            )
          : TaskModel.create(
              userId: userId,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              priority: _selectedPriority,
              category: _selectedCategory,
              dueDate: finalDueDate,
              imagePath: _imagePath,
              subtasks: List.from(_subtasks),
            );

      print('SAVING TASK: Calling ${_isEditing ? "updateTask" : "addTask"}...');

      final taskService = ref.read(taskServiceProvider);
      final success = _isEditing
          ? await taskService.updateTask(task)
          : await taskService.addTask(task);

      print('SAVING TASK: Result = $success');

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Task updated successfully!'
                  : 'Task added successfully!',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        if (mounted) {
          Navigator.of(context).maybePop();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save task. Check logs for details.',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('ERROR in _saveTask: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Confirm delete
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Task?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
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
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final taskService = ref.read(taskServiceProvider);
        final success = await taskService.deleteTask(widget.taskToEdit!.id);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Task deleted successfully',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          if (mounted) {
            Navigator.of(context).maybePop();
          }
        }
      } catch (e) {
        print('Error deleting task: $e');
      }
    }
  }
}
