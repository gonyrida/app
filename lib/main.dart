import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/environment_config.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'providers/user_session_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables and initialize Supabase
  try {
    await EnvironmentConfig.load();
    await SupabaseService.instance.initialize();
  } catch (e) {
    print('Failed to initialize services: $e');
  }

  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => UserSessionProvider()),
        provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

/// AuthWrapper - Checks authentication status and shows appropriate screen
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      // Check Supabase authentication state instead of SharedPreferences
      final supabaseAuth = SupabaseService.instance.isAuthenticated;

      // Load saved theme preference
      if (mounted) {
        final themeProvider = provider.Provider.of<ThemeProvider>(
          context,
          listen: false,
        );
        final prefs = await SharedPreferences.getInstance();
        final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
        if (isDarkMode) {
          themeProvider.setThemeMode(ThemeMode.dark);
        }
      }

      if (kDebugMode) {
        print('DEBUG: Supabase auth status: $supabaseAuth');
        print(
            'DEBUG: Current user: ${SupabaseService.instance.currentUser?.email}');
      }

      if (mounted) {
        setState(() {
          _isLoggedIn = supabaseAuth;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking auth status: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking auth
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white, // Ensure white background
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Loading...',
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Get router with initial location based on auth status
    final router = AppRouter.getRouter(_isLoggedIn);

    return provider.Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
