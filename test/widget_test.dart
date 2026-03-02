// Flutter Task Management App - Widget Tests
// Tests for Task components and functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_management/main.dart';
import 'package:task_management/features/task_management/domain/models/task_model.dart';
import 'package:task_management/providers/task_provider.dart';

import 'package:task_management/widgets/header.dart';
import 'package:task_management/widgets/search_bar.dart';
import 'package:task_management/widgets/filter_tabs.dart';
import 'package:task_management/widgets/checkbox.dart';
import 'package:task_management/widgets/task_item.dart';

void main() {
  group('Task Management App Widget Tests', () {
    // Test 1: App launches successfully
    testWidgets('App launches and displays HomeScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify the app title is displayed
      expect(find.text("Today's Tasks"), findsOneWidget);
    });

    // Test 2: Header widget displays correctly
    testWidgets('Header displays title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Header(title: 'Test Header'),
          ),
        ),
      );

      expect(find.text('Test Header'), findsOneWidget);
    });

    // Test 3: SearchBar widget works
    testWidgets('SearchBar accepts text input', (WidgetTester tester) async {
      String searchValue = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(
              value: searchValue,
              onChangeText: (value) => searchValue = value,
              placeholder: 'Search...',
            ),
          ),
        ),
      );

      // Enter text in search field
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      expect(searchValue, 'test query');
    });

    // Test 4: FilterTabs widget displays all tabs
    testWidgets('FilterTabs displays all filter options',
        (WidgetTester tester) async {
      FilterType currentFilter = FilterType.all;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterTabs(
              value: currentFilter,
              onChange: (filter) => currentFilter = filter,
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    // Test 5: Checkbox widget toggles
    testWidgets('Checkbox toggles on tap', (WidgetTester tester) async {
      bool isChecked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckboxWidget(
              checked: isChecked,
              onToggle: () => isChecked = !isChecked,
            ),
          ),
        ),
      );

      // Tap the checkbox
      await tester.tap(find.byType(CheckboxWidget));
      await tester.pump();

      expect(isChecked, true);
    });

    // Test 6: TaskItem displays task information
    testWidgets('TaskItem displays task details correctly',
        (WidgetTester tester) async {
      final testTask = TaskModel.create(
        userId: 'test-user-id',
        title: 'Test Task',
        category: 'Development',
        priority: Priority.high,
      )..isCompleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItem(
              task: testTask,
              onToggle: () {},
            ),
          ),
        ),
      );

      // Verify task details are displayed
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Development'), findsOneWidget);
    });

    // Test 7: TaskProvider filtering logic
    testWidgets('TaskProvider filters tasks correctly',
        (WidgetTester tester) async {
      final taskProvider = TaskProvider();

      // Initially should have sample tasks
      expect(taskProvider.tasks.isNotEmpty, true);

      // Test search filter
      taskProvider.setQuery('Design');
      await tester.pump();
      // Filtered results should be subset of all tasks
      expect(
          taskProvider.filteredTasks.length <= taskProvider.tasks.length, true);

      // Clear search and test pending filter
      taskProvider.setQuery('');
      taskProvider.setFilter(FilterType.pending);
      await tester.pump();
      expect(taskProvider.filteredTasks.where((t) => t.isCompleted).length, 0);

      // Test completed filter
      taskProvider.setFilter(FilterType.completed);
      await tester.pump();
      expect(taskProvider.filteredTasks.where((t) => !t.isCompleted).length, 0);
    });

    // Test 8: TaskProvider toggle functionality
    testWidgets('TaskProvider toggles task completion',
        (WidgetTester tester) async {
      final taskProvider = TaskProvider();
      final initialCompletedCount =
          taskProvider.tasks.where((t) => t.isCompleted).length;

      // Toggle a non-completed task
      final nonCompletedTask =
          taskProvider.tasks.firstWhere((t) => !t.isCompleted);
      taskProvider.toggleTask(int.tryParse(nonCompletedTask.id) ?? 0);
      await tester.pump();

      expect(
        taskProvider.tasks.where((t) => t.isCompleted).length,
        initialCompletedCount + 1,
      );
    });
  });
}
