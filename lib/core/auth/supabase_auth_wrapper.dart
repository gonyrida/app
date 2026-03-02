import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/services/supabase_service.dart';
import '../providers/supabase_user_provider.dart';
import '../screens/enhanced_auth_screen.dart';

/// Supabase Authentication Wrapper
/// Handles authentication state and redirects accordingly
class SupabaseAuthWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const SupabaseAuthWrapper({super.key, required this.child});

  @override
  ConsumerState<SupabaseAuthWrapper> createState() => _SupabaseAuthWrapperState();
}

class _SupabaseAuthWrapperState extends ConsumerState<SupabaseAuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Initialize Supabase service
      await SupabaseService.instance.initialize();
      
      // Initialize session provider
      final sessionProvider = ref.read(supabaseSessionProvider);
      await sessionProvider.initialize();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Listen to auth state changes
    ref.listen<AuthState>(supabaseAuthProvider, (previous, next) {
      if (next.session != null && previous?.session == null) {
        // User just signed in - reinitialize session with fresh data
        final sessionProvider = ref.read(supabaseSessionProvider);
        sessionProvider.initialize();
      } else if (next.session == null && previous?.session != null) {
        // User just signed out - clear session data
        final sessionProvider = ref.read(supabaseSessionProvider);
        sessionProvider.clearSession();
        context.go('/auth');
      }
    });

    // Check authentication status
    final authState = ref.watch(supabaseAuthProvider);
    final isAuthenticated = authState.session != null;

    if (!isAuthenticated) {
      return const EnhancedSupabaseAuthScreen();
    }

    return widget.child;
  }
}

/// Supabase Protected Route
/// Wraps routes that require authentication
class SupabaseProtectedRoute extends ConsumerWidget {
  final Widget child;

  const SupabaseProtectedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(supabaseAuthProvider);
    final isAuthenticated = authState.session != null;

    if (!isAuthenticated) {
      // Redirect to auth screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/auth');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return child;
  }
}

/// Supabase Auth Guard
/// Can be used in GoRouter for route protection
class SupabaseAuthGuard {
  static bool canAccess(BuildContext context, GoRouterState state) {
    final supabase = SupabaseService.instance;
    return supabase.isAuthenticated;
  }

  static String redirect(BuildContext context, GoRouterState state) {
    final supabase = SupabaseService.instance;
    if (!supabase.isAuthenticated) {
      return '/auth';
    }
    return state.location;
  }
}
