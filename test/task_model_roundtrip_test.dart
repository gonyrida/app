import 'package:flutter_test/flutter_test.dart';
import '../lib/features/task_management/domain/models/task_model.dart';

void main() {
  group('TaskModel Database Compatibility Tests', () {
    test('Round trip: toSupabaseMap -> fromSupabase should preserve priority', () {
      // Test all priority values
      for (final priority in Priority.values) {
        // Create task with specific priority
        final originalTask = TaskModel.create(
          userId: 'test-user',
          title: 'Test Task with ${priority.name}',
          description: 'Test Description',
          priority: priority,
          category: 'Personal',
        );
        
        // Convert to Supabase format
        final supabaseMap = originalTask.toSupabaseMap();
        
        // Verify priority is lowercase in the map
        expect(supabaseMap['priority'], equals(priority.name.toLowerCase()));
        
        // Convert back from Supabase format
        final restoredTask = TaskModel.fromSupabase(supabaseMap);
        
        // Verify priority is preserved
        expect(restoredTask.priority, equals(originalTask.priority));
      }
    });
    
    test('fromSupabase should handle lowercase priority strings from database', () {
      final testCases = [
        {'priority': 'low', 'expected': Priority.low},
        {'priority': 'medium', 'expected': Priority.medium},
        {'priority': 'high', 'expected': Priority.high},
        {'priority': 'LOW', 'expected': Priority.low}, // Should handle uppercase
        {'priority': 'Medium', 'expected': Priority.medium}, // Should handle mixed case
        {'priority': 'HIGH', 'expected': Priority.high}, // Should handle uppercase
        {'priority': 'invalid', 'expected': Priority.medium}, // Should default to medium
      ];
      
      for (final testCase in testCases) {
        final map = {
          'id': 'test-id',
          'user_id': 'test-user',
          'title': 'Test Task',
          'priority': testCase['priority'],
          'category': 'Personal',
          'is_completed': false,
          'subtasks': [],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        final task = TaskModel.fromSupabase(map);
        expect(task.priority, equals(testCase['expected']),
            reason: 'Failed for priority: ${testCase['priority']}');
      }
    });
  });
}
