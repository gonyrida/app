import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/config/environment_config.dart';
import 'core/services/supabase_service.dart';
import 'core/auth/supabase_auth_wrapper.dart';
import 'screens/enhanced_auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/enhanced_security_settings.dart';

/// Main App with Supabase Integration
class SupabaseApp extends ConsumerStatefulWidget {
  const SupabaseApp({super.key});

  @override
  ConsumerState<SupabaseApp> createState() => _SupabaseAppState();
}

class _SupabaseAppState extends ConsumerState<SupabaseApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _initializeRouter();
  }

  void _initializeRouter() {
    _router = GoRouter(
      initialLocation: '/auth',
      redirect: (context, state) {
        final supabase = SupabaseService.instance;
        final isAuthenticated = supabase.isAuthenticated;
        
        // If not authenticated and trying to access protected route
        if (!isAuthenticated && !state.location.startsWith('/auth')) {
          return '/auth';
        }
        
        // If authenticated and trying to access auth route
        if (isAuthenticated && state.location.startsWith('/auth')) {
          return '/home';
        }
        
        return null;
      },
      routes: [
        // Authentication routes
        GoRoute(
          path: '/auth',
          builder: (context, state) => const EnhancedSupabaseAuthScreen(),
        ),
        
        // Protected routes
        GoRoute(
          path: '/home',
          builder: (context, state) => const SupabaseProtectedRoute(
            child: HomeScreen(),
          ),
        ),
        
        GoRoute(
          path: '/profile',
          builder: (context, state) => const SupabaseProtectedRoute(
            child: ProfileScreen(),
          ),
        ),
        
        GoRoute(
          path: '/security',
          builder: (context, state) => const SupabaseProtectedRoute(
            child: EnhancedSecuritySettingsScreen(),
          ),
        ),
        
        GoRoute(
          path: '/add-task',
          builder: (context, state) => const SupabaseProtectedRoute(
            child: AddTaskScreen(),
          ),
        ),
        
        GoRoute(
          path: '/edit-task/:id',
          builder: (context, state) {
            final taskId = state.pathParameters['id']!;
            return SupabaseProtectedRoute(
              child: AddTaskScreen(taskId: taskId),
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.location,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

/// App initialization
Future<void> initializeApp() async {
  try {
    // Load environment configuration
    await EnvironmentConfig.load();
    
    // Initialize Supabase
    await SupabaseService.instance.initialize();
    
    print('App initialized successfully');
  } catch (e) {
    print('Failed to initialize app: $e');
    rethrow;
  }
}
