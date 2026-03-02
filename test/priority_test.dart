import 'package:flutter_test/flutter_test.dart';
import '../lib/features/task_management/domain/models/task_model.dart';

void main() {
  group('Priority Tests', () {
    test('Priority enum values should be converted to lowercase for database',
        () {
      // Test all priority values
      for (final priority in Priority.values) {
        print(
            'Priority: $priority -> name: "${priority.name}" -> lowercase: "${priority.name.toLowerCase()}"');

        // The toSupabaseMap should produce lowercase values that match database constraint
        expect(
            ['low', 'medium', 'high'], contains(priority.name.toLowerCase()));
      }
    });

    test('TaskModel toSupabaseMap should include correct priority format', () {
      final task = TaskModel.create(
        userId: 'test-user',
        title: 'Test Task',
        description: 'Test Description',
        priority: Priority.low,
        category: 'Personal',
      );

      final taskMap = task.toSupabaseMap();
      print('Task priority in map: "${taskMap['priority']}"');
      print('Full map: $taskMap');

      // Should be lowercase string to match database constraint
      expect(taskMap['priority'], isA<String>());
      expect(taskMap['priority'], equals('low'));
    });
  });
}
