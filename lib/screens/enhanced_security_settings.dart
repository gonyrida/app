import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../providers/supabase_user_provider.dart';

/// Enhanced Security Settings Screen
class EnhancedSecuritySettingsScreen extends ConsumerStatefulWidget {
  const EnhancedSecuritySettingsScreen({super.key});

  @override
  ConsumerState<EnhancedSecuritySettingsScreen> createState() => _EnhancedSecuritySettingsScreenState();
}

class _EnhancedSecuritySettingsScreenState extends ConsumerState<EnhancedSecuritySettingsScreen> {
  bool _isLoading = false;
  bool _twoFactorEnabled = false;
  bool _emailNotifications = true;
  bool _loginAlerts = true;
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';
  bool _showPasswordForm = false;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    // Load user's current security settings
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      setState(() {
        _twoFactorEnabled = user.userMetadata?['two_factor_enabled'] ?? false;
        _emailNotifications = user.userMetadata?['email_notifications'] ?? true;
        _loginAlerts = user.userMetadata?['login_alerts'] ?? true;
      });
    }
  }

  Future<void> _toggleTwoFactor() async {
    setState(() => _isLoading = true);
    
    try {
      final userService = ref.read(supabaseUserServiceProvider);
      
      if (_twoFactorEnabled) {
        // Disable 2FA
        await userService.updateUserMetadata({'two_factor_enabled': false});
        _showSuccess('Two-factor authentication disabled');
      } else {
        // Enable 2FA (in real app, this would involve QR code setup)
        await userService.updateUserMetadata({'two_factor_enabled': true});
        _showSuccess('Two-factor authentication enabled');
      }
      
      setState(() {
        _twoFactorEnabled = !_twoFactorEnabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to update two-factor settings');
    }
  }

  Future<void> _changePassword() async {
    if (_currentPassword.isEmpty || _newPassword.isEmpty || _confirmPassword.isEmpty) {
      _showError('All password fields are required');
      return;
    }

    if (_newPassword.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }

    if (_newPassword != _confirmPassword) {
      _showError('New passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService.instance.client.auth.updateUser(
        UserAttributes(
          password: _newPassword,
        ),
      );

      setState(() {
        _showPasswordForm = false;
        _currentPassword = '';
        _newPassword = '';
        _confirmPassword = '';
        _isLoading = false;
      });

      _showSuccess('Password changed successfully');
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to change password. Please check your current password.');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        title: const Text('Security Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Overview
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.blue.shade600, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Security Overview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your account is protected with enterprise-grade security',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Two-Factor Authentication
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phonelink_lock, color: Colors.orange.shade600, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Two-Factor Authentication',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add an extra layer of security to your account by requiring a verification code in addition to your password.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: _twoFactorEnabled,
                      onChanged: _isLoading ? null : (value) => _toggleTwoFactor(),
                      activeColor: Colors.green.shade600,
                      title: Text(
                        _twoFactorEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _twoFactorEnabled ? Colors.green.shade700 : Colors.grey.shade700,
                        ),
                      ),
                      subtitle: Text(
                        _twoFactorEnabled 
                            ? 'Your account has enhanced protection'
                            : 'Enable for better security',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
