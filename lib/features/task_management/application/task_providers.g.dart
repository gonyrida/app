// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseTaskRepositoryHash() =>
    r'c697b4fe18ce834a3568ef63f298d3f48e34802a';

/// Provider for Supabase task repository
///
/// Copied from [supabaseTaskRepository].
@ProviderFor(supabaseTaskRepository)
final supabaseTaskRepositoryProvider =
    AutoDisposeProvider<SupabaseTaskRepository>.internal(
  supabaseTaskRepository,
  name: r'supabaseTaskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supabaseTaskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SupabaseTaskRepositoryRef
    = AutoDisposeProviderRef<SupabaseTaskRepository>;
String _$allTasksHash() => r'06651a17cb3384b39b6b1c398920253b14e0e947';

/// Provider for all tasks from Supabase
///
/// Copied from [allTasks].
@ProviderFor(allTasks)
final allTasksProvider = AutoDisposeFutureProvider<List<TaskModel>>.internal(
  allTasks,
  name: r'allTasksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllTasksRef = AutoDisposeFutureProviderRef<List<TaskModel>>;
String _$filteredTasksHash() => r'ebbb49bc256ada00640bbea16d56882f4cd43368';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for filtered tasks based on completion status
///
/// Copied from [filteredTasks].
@ProviderFor(filteredTasks)
const filteredTasksProvider = FilteredTasksFamily();

/// Provider for filtered tasks based on completion status
///
/// Copied from [filteredTasks].
class FilteredTasksFamily extends Family<AsyncValue<List<TaskModel>>> {
  /// Provider for filtered tasks based on completion status
  ///
  /// Copied from [filteredTasks].
  const FilteredTasksFamily();

  /// Provider for filtered tasks based on completion status
  ///
  /// Copied from [filteredTasks].
  FilteredTasksProvider call({
    required TaskFilter filter,
    String searchQuery = '',
  }) {
    return FilteredTasksProvider(
      filter: filter,
      searchQuery: searchQuery,
    );
  }

  @override
  FilteredTasksProvider getProviderOverride(
    covariant FilteredTasksProvider provider,
  ) {
    return call(
      filter: provider.filter,
      searchQuery: provider.searchQuery,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredTasksProvider';
}

/// Provider for filtered tasks based on completion status
///
/// Copied from [filteredTasks].
class FilteredTasksProvider extends AutoDisposeFutureProvider<List<TaskModel>> {
  /// Provider for filtered tasks based on completion status
  ///
  /// Copied from [filteredTasks].
  FilteredTasksProvider({
    required TaskFilter filter,
    String searchQuery = '',
  }) : this._internal(
          (ref) => filteredTasks(
            ref as FilteredTasksRef,
            filter: filter,
            searchQuery: searchQuery,
          ),
          from: filteredTasksProvider,
          name: r'filteredTasksProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredTasksHash,
          dependencies: FilteredTasksFamily._dependencies,
          allTransitiveDependencies:
              FilteredTasksFamily._allTransitiveDependencies,
          filter: filter,
          searchQuery: searchQuery,
        );

  FilteredTasksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
    required this.searchQuery,
  }) : super.internal();

  final TaskFilter filter;
  final String searchQuery;

  @override
  Override overrideWith(
    FutureOr<List<TaskModel>> Function(FilteredTasksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredTasksProvider._internal(
        (ref) => create(ref as FilteredTasksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TaskModel>> createElement() {
    return _FilteredTasksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredTasksProvider &&
        other.filter == filter &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FilteredTasksRef on AutoDisposeFutureProviderRef<List<TaskModel>> {
  /// The parameter `filter` of this provider.
  TaskFilter get filter;

  /// The parameter `searchQuery` of this provider.
  String get searchQuery;
}

class _FilteredTasksProviderElement
    extends AutoDisposeFutureProviderElement<List<TaskModel>>
    with FilteredTasksRef {
  _FilteredTasksProviderElement(super.provider);

  @override
  TaskFilter get filter => (origin as FilteredTasksProvider).filter;
  @override
  String get searchQuery => (origin as FilteredTasksProvider).searchQuery;
}

String _$todaysTasksHash() => r'86113d699187d8935fb65bbf1f1b8aec433210d5';

/// Provider for today's tasks
///
/// Copied from [todaysTasks].
@ProviderFor(todaysTasks)
final todaysTasksProvider = AutoDisposeFutureProvider<List<TaskModel>>.internal(
  todaysTasks,
  name: r'todaysTasksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todaysTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodaysTasksRef = AutoDisposeFutureProviderRef<List<TaskModel>>;
String _$taskStatsHash() => r'7349e4d95aa92200194b626637aaa4838fbf2c2d';

/// Provider for task statistics
///
/// Copied from [taskStats].
@ProviderFor(taskStats)
final taskStatsProvider = AutoDisposeFutureProvider<TaskStats>.internal(
  taskStats,
  name: r'taskStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TaskStatsRef = AutoDisposeFutureProviderRef<TaskStats>;
String _$taskByIdHash() => r'0e8729e3062c125a427db80e5961544a9aec9b97';

/// Provider for a single task by ID
///
/// Copied from [taskById].
@ProviderFor(taskById)
const taskByIdProvider = TaskByIdFamily();

/// Provider for a single task by ID
///
/// Copied from [taskById].
class TaskByIdFamily extends Family<AsyncValue<TaskModel?>> {
  /// Provider for a single task by ID
  ///
  /// Copied from [taskById].
  const TaskByIdFamily();

  /// Provider for a single task by ID
  ///
  /// Copied from [taskById].
  TaskByIdProvider call(
    String id,
  ) {
    return TaskByIdProvider(
      id,
    );
  }

  @override
  TaskByIdProvider getProviderOverride(
    covariant TaskByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskByIdProvider';
}

/// Provider for a single task by ID
///
/// Copied from [taskById].
class TaskByIdProvider extends AutoDisposeFutureProvider<TaskModel?> {
  /// Provider for a single task by ID
  ///
  /// Copied from [taskById].
  TaskByIdProvider(
    String id,
  ) : this._internal(
          (ref) => taskById(
            ref as TaskByIdRef,
            id,
          ),
          from: taskByIdProvider,
          name: r'taskByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$taskByIdHash,
          dependencies: TaskByIdFamily._dependencies,
          allTransitiveDependencies: TaskByIdFamily._allTransitiveDependencies,
          id: id,
        );

  TaskByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<TaskModel?> Function(TaskByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskByIdProvider._internal(
        (ref) => create(ref as TaskByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TaskModel?> createElement() {
    return _TaskByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TaskByIdRef on AutoDisposeFutureProviderRef<TaskModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TaskByIdProviderElement
    extends AutoDisposeFutureProviderElement<TaskModel?> with TaskByIdRef {
  _TaskByIdProviderElement(super.provider);

  @override
  String get id => (origin as TaskByIdProvider).id;
}

String _$taskServiceHash() => r'33aada9249143a467a2690c7d7c872ca52518863';

/// Task Service provider
///
/// Copied from [taskService].
@ProviderFor(taskService)
final taskServiceProvider = AutoDisposeProvider<TaskService>.internal(
  taskService,
  name: r'taskServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TaskServiceRef = AutoDisposeProviderRef<TaskService>;
String _$taskNotifierHash() => r'3c41f70c458e7134fda54bf205714303aa7521b9';

/// Task Notifier provider
///
/// Copied from [taskNotifier].
@ProviderFor(taskNotifier)
final taskNotifierProvider = AutoDisposeProvider<TaskNotifier>.internal(
  taskNotifier,
  name: r'taskNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TaskNotifierRef = AutoDisposeProviderRef<TaskNotifier>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
