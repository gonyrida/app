import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import '../core/services/supabase_service.dart';
import '../providers/supabase_user_provider.dart';
import 'package:go_router/go_router.dart';

/// Supabase Authentication Screen
/// Handles login, signup, and password reset
class SupabaseAuthScreen extends ConsumerStatefulWidget {
  const SupabaseAuthScreen({super.key});

  @override
  ConsumerState<SupabaseAuthScreen> createState() => _SupabaseAuthScreenState();
}

class _SupabaseAuthScreenState extends ConsumerState<SupabaseAuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (SupabaseService.instance.isAuthenticated) {
        context.go('/home');
      }
    });
  }

  Future<void> _handleAuthResponse(AuthResponse response) async {
    setState(() {
      _isLoading = false;
    });

    if (response.user != null) {
      // Initialize the session provider
      final sessionProvider = ref.read(supabaseSessionProvider);
      await sessionProvider.initialize();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? 'Login successful!' : 'Account created!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to home
        context.go('/home');
      }
    } else {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = ref.watch(supabaseUserServiceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Logo and Title
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.task_alt,
                      size: 40,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Task Manager',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Welcome back!' : 'Create your account',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Auth Form
              SupaEmailAuth(
                redirectTo: kIsWeb ? null : 'io.supabase.flutter://login-callback/',
                onSignInComplete: (response) async {
                  setState(() => _isLoading = true);
                  await _handleAuthResponse(response);
                },
                onSignUpComplete: (response) async {
                  setState(() => _isLoading = true);
                  await _handleAuthResponse(response);
                },
                onError: (error) {
                  setState(() => _isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error.message ?? 'An error occurred'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                metadataFields: [
                  // Only show name field during signup
                  if (!_isLogin)
                    MetaDataField(
                      prefixIcon: const Icon(Icons.person),
                      label: 'Full Name',
                      key: 'name',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Toggle between Login and Signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? "Don't have an account?" : 'Already have an account?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin ? 'Sign Up' : 'Sign In',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Social Login Buttons
              SupaSocialsAuth(
                colored: true,
                providerIcons: const [
                  ProviderIcon.apple,
                  ProviderIcon.google,
                  ProviderIcon.github,
                ],
                onSuccess: (session) async {
                  setState(() => _isLoading = true);
                  final sessionProvider = ref.read(supabaseSessionProvider);
                  await sessionProvider.initialize();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login successful!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.go('/home');
                  }
                },
                onError: (error) {
                  setState(() => _isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error.message ?? 'Social login failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 32),
              
              // Forgot Password (only for login)
              if (_isLogin)
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      _showForgotPasswordDialog();
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  final userService = ref.read(supabaseUserServiceProvider);
                  await userService.resetPassword(email);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to send reset email: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
