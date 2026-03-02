import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:go_router/go_router.dart';
import '../providers/supabase_user_provider.dart';
import '../features/task_management/application/supabase_task_providers.dart';
import '../features/task_management/domain/models/task_model.dart';
import '../core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Updated Profile Screen using Supabase
class SupabaseProfileScreen extends ConsumerStatefulWidget {
  const SupabaseProfileScreen({super.key});

  @override
  ConsumerState<SupabaseProfileScreen> createState() => _SupabaseProfileScreenState();
}

class _SupabaseProfileScreenState extends ConsumerState<SupabaseProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isEditing = false;
  bool _darkMode = false;
  bool _notifications = true;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    
    // Force refresh when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
    
    // Listen to auth state changes to refresh profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(supabaseAuthProvider, (previous, next) {
        if (next.session != null && previous?.session == null) {
          // User just signed in, reload profile data
          debugPrint('Auth state changed, reloading profile');
          _loadProfileData();
        }
      });
    });
  }

  Future<void> _loadProfileData() async {
    // Clear previous user's data first
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _locationController.clear();
      _bioController.clear();
      _avatarUrl = null;
      _darkMode = false;
      _notifications = true;
    });
    
    final userService = ref.read(supabaseUserServiceProvider);
    final profile = await userService.getCurrentUserProfile();
    
    if (profile != null && mounted) {
      debugPrint('Loading profile data for user: ${profile.email}');
      debugPrint('Avatar URL from database: ${profile.avatarPath}');
      
      setState(() {
        _nameController.text = profile.name;
        _emailController.text = profile.email;
        _phoneController.text = profile.phone ?? '';
        _locationController.text = profile.location ?? '';
        _bioController.text = profile.bio ?? '';
        _avatarUrl = profile.avatarPath;
        _darkMode = profile.themeMode == 'dark';
        _notifications = profile.notificationsEnabled;
      });
      
      debugPrint('Avatar URL set in state: $_avatarUrl');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      final userService = ref.read(supabaseUserServiceProvider);
      
      await userService.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        avatarUrl: _avatarUrl,
        themeMode: _darkMode ? 'dark' : 'light',
        notificationsEnabled: _notifications,
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload profile data to ensure fresh state
        await _loadProfileData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      final userService = ref.read(supabaseUserServiceProvider);
      await userService.signOut();
      
      // Navigation will be handled by auth wrapper
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskStatsAsync = ref.watch(supabaseTaskStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? NetworkImage(
                            _avatarUrl!,
                            headers: {'Cache-Control': 'no-cache'},
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person, size: 60, color: Colors.blue.shade600);
                            },
                          )
                        : null,
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? Icon(Icons.person, size: 60, color: Colors.blue.shade600)
                        : null,
                    key: ValueKey('avatar_${_avatarUrl ?? 'default'}'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _emailController.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Task Statistics
            taskStatsAsync.when(
              data: (stats) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Statistics',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Total', stats.total.toString(), Colors.blue),
                          _buildStatItem('Done', stats.completed.toString(), Colors.green),
                          _buildStatItem('Pending', stats.pending.toString(), Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Failed to load statistics'),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Profile Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEditableField('Name', _nameController, Icons.person),
                    _buildEditableField('Email', _emailController, Icons.email, enabled: false),
                    _buildEditableField('Phone', _phoneController, Icons.phone),
                    _buildEditableField('Location', _locationController, Icons.location_on),
                    _buildEditableField('Bio', _bioController, Icons.info_outline, maxLines: 3),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Toggle dark theme'),
                      value: _darkMode,
                      onChanged: _isEditing ? (value) {
                        setState(() {
                          _darkMode = value;
                        });
                      } : null,
                    ),
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Task reminders and updates'),
                      value: _notifications,
                      onChanged: _isEditing ? (value) {
                        setState(() {
                          _notifications = value;
                        });
                      } : null,
                    ),
                    ListTile(
                      leading: Icon(Icons.security, color: Colors.blue.shade600),
                      title: const Text('Security Settings'),
                      subtitle: const Text('Manage password and authentication'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/security'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(
    String label, 
    TextEditingController controller, 
    IconData icon, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          enabled && _isEditing
              ? TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                )
              : Text(
                  controller.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ],
      ),
    );
  }
}
