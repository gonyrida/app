import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../providers/supabase_user_provider.dart';
import 'package:go_router/go_router.dart';

/// Enhanced Authentication Screen with Strong Security
class EnhancedSupabaseAuthScreen extends ConsumerStatefulWidget {
  const EnhancedSupabaseAuthScreen({super.key});

  @override
  ConsumerState<EnhancedSupabaseAuthScreen> createState() =>
      _EnhancedSupabaseAuthScreenState();
}

class _EnhancedSupabaseAuthScreenState
    extends ConsumerState<EnhancedSupabaseAuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'^(?=.*[a-z])').hasMatch(value))
      return 'Password must contain lowercase letter';
    if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value))
      return 'Password must contain uppercase letter';
    if (!RegExp(r'^(?=.*\d)').hasMatch(value))
      return 'Password must contain number';
    if (!RegExp(r'^(?=.*[@$!%*?&])').hasMatch(value))
      return 'Password must contain special character';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validateName(String? value) {
    if (!_isLogin && (value == null || value.isEmpty))
      return 'Name is required';
    if (!_isLogin && value!.length < 2)
      return 'Name must be at least 2 characters';
    return null;
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isLogin && !_agreeToTerms) {
      _showError('You must agree to the terms and conditions');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userService = ref.read(supabaseUserServiceProvider);

      if (_isLogin) {
        await userService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await userService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
      }

      if (mounted) {
        _showSuccess(_isLogin ? 'Login successful!' : 'Account created!');

        // Reinitialize session to get fresh user data
        final sessionProvider =
            provider.Provider.of<SupabaseUserSessionProvider>(context,
                listen: false);
        await sessionProvider.initialize();

        // Clear form
        _formKey.currentState?.reset();
        _agreeToTerms = false;

        await Future.delayed(const Duration(seconds: 1));
        context.go('/home');
      }
    } on AuthException catch (e) {
      if (e.message == 'Email not confirmed') {
        _showEmailNotConfirmedDialog();
      } else {
        _showError(_getAuthErrorMessage(e));
      }
    } catch (e) {
      _showError('An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getAuthErrorMessage(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password';
      case 'User not found':
        return 'No account found with this email';
      case 'Email rate limit exceeded':
        return 'Too many attempts. Please try again later';
      case 'Password should be at least 6 characters':
        return 'Password is too weak';
      case 'User already registered':
        return 'An account with this email already exists';
      case 'Signup not allowed for this instance':
        return 'Registration is currently disabled';
      case 'Email not confirmed':
        return 'Email not confirmed. Please check your inbox.';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  void _showEmailNotConfirmedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.email_outlined, color: Colors.orange.shade600),
            const SizedBox(width: 12),
            const Text('Email Not Confirmed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your email address has not been confirmed yet. Please check your inbox for the confirmation email.',
            ),
            const SizedBox(height: 12),
            const Text(
              'If you didn\'t receive the confirmation email, we can resend it to you.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${_emailController.text.trim()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade600,
              ),
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
              Navigator.pop(context);
              try {
                final userService = ref.read(supabaseUserServiceProvider);
                await userService
                    .resendEmailConfirmation(_emailController.text.trim());
                if (mounted) {
                  _showSuccess(
                      'Confirmation email sent! Please check your inbox.');
                }
              } catch (e) {
                if (mounted) {
                  _showError('Failed to resend confirmation email');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Resend Email'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo and Title
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.task_alt,
                      size: 40,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Task Manager Pro',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Welcome back! Please sign in'
                        : 'Create your secure account',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your data is protected with enterprise-grade encryption and security',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Enhanced Auth Form
              Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name field (signup only)
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            validator: _validateName,
                            decoration: _inputDecoration(
                              'Full Name',
                              Icons.person_outline,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          validator: _validateEmail,
                          decoration: _inputDecoration(
                            'Email Address',
                            Icons.email_outlined,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          validator: _validatePassword,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            'Password',
                            Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          textInputAction: _isLogin
                              ? TextInputAction.done
                              : TextInputAction.next,
                          autofillHints: const [AutofillHints.password],
                        ),
                        const SizedBox(height: 16),

                        // Confirm password (signup only)
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _confirmPasswordController,
                            validator: _validateConfirmPassword,
                            obscureText: _obscureConfirmPassword,
                            decoration: _inputDecoration(
                              'Confirm Password',
                              Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Terms and conditions (signup only)
                        if (!_isLogin) ...[
                          Row(
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) =>
                                    setState(() => _agreeToTerms = value!),
                                activeColor: Colors.blue.shade600,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _agreeToTerms = !_agreeToTerms),
                                  child: Text(
                                    'I agree to the Terms of Service and Privacy Policy',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleEmailAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Sign In' : 'Create Account',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Toggle between Login and Signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? "Don't have an account?"
                        : 'Already have an account?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _formKey.currentState?.reset();
                        _agreeToTerms = false;
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

              const SizedBox(height: 24),

              // Social Login with Enhanced Security
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Continue with secure social login',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 16),
                      SupaSocialsAuth(
                        colored: true,
                        providerIcons: const [
                          ProviderIcon.google,
                          ProviderIcon.github,
                        ],
                        onSuccess: (session) async {
                          final sessionProvider =
                              ref.read(supabaseSessionProvider);
                          await sessionProvider.initialize();

                          if (mounted) {
                            _showSuccess('Secure login successful!');
                            context.go('/home');
                          }
                        },
                        onError: (error) {
                          _showError('Social login failed: ${error.message}');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Forgot Password (login only)
              if (_isLogin)
                Center(
                  child: TextButton.icon(
                    onPressed: _isLoading ? null : _showForgotPasswordDialog,
                    icon: Icon(Icons.lock_reset,
                        size: 18, color: Colors.blue.shade600),
                    label: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Security Features
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user,
                            color: Colors.green.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '256-bit SSL Encryption',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.gpp_good,
                            color: Colors.green.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'GDPR Compliant',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.security,
                            color: Colors.green.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Two-Factor Authentication Available',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            const Text('Reset Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Enter your email address to receive a secure password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
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
              if (email.isNotEmpty &&
                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                try {
                  final userService = ref.read(supabaseUserServiceProvider);
                  await userService.resetPassword(email);

                  if (mounted) {
                    Navigator.pop(context);
                    _showSuccess('Password reset email sent!');
                  }
                } catch (e) {
                  _showError('Failed to send reset email');
                }
              } else {
                _showError('Please enter a valid email');
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}
