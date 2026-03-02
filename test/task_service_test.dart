import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/features/task_management/application/task_providers.dart';
import '../lib/features/task_management/domain/models/task_model.dart';

void main() {
  group('TaskService Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('TaskService should be accessible without LateInitializationError', () {
      final taskService = container.read(taskServiceProvider);
      expect(taskService, isNotNull);
      expect(taskService, isA<TaskService>());
    });

    test('TaskNotifier should be accessible without LateInitializationError', () {
      final taskNotifier = container.read(taskNotifierProvider);
      expect(taskNotifier, isNotNull);
      expect(taskNotifier, isA<TaskNotifier>());
    });
  });
}
