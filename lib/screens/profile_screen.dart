import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';
import '../features/task_management/application/supabase_task_providers.dart'
    as supabase_providers;
import '../features/task_management/application/task_providers.dart';
import '../providers/user_session_provider.dart';
import '../providers/supabase_user_provider.dart';
import '../data/repositories/supabase_user_repository.dart';

/// ProfileScreen - User profile with editable info
///
/// Features:
/// - Circular avatar (editable via image_picker)
/// - User info: name, email, phone, location, bio (editable)
/// - Sections: Edit Profile, Notifications, Security, Theme, Help
/// - Logout red button
/// - Toast "Profile Updated" on save
/// - Bottom nav Profile active
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Chinit Hem');
  final _emailController = TextEditingController(text: 'chinithem81@gmail.com');
  final _phoneController = TextEditingController(text: '+855 011 311 161');

  final _locationController =
      TextEditingController(text: 'Phnom Penh, Cambodia');
  final _bioController = TextEditingController(
    text: 'Flutter developer. Love building beautiful and productive apps!',
  );

  String? _avatarPath;
  bool _isEditing = false;
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    // Clear avatar path to prevent showing previous user's image
    _avatarPath = null;

    // Load session data first, then Isar data (only for missing fields)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasSession = _loadSessionData();
      _loadProfile(hasSession);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Clear avatar path when dependencies change (user switch)
    _avatarPath = null;

    // Reload session data when dependencies change (e.g., when navigating back to this screen)
    // Then reload Isar data only for fields not in session
    final hasSession = _loadSessionData();
    _loadProfile(hasSession);
  }

  /// Load email and name from session (login/signup cache)
  /// Returns true if session data was found
  bool _loadSessionData() {
    final sessionProvider =
        provider.Provider.of<UserSessionProvider>(context, listen: false);
    if (sessionProvider.email != null) {
      setState(() {
        _emailController.text = sessionProvider.email!;
        if (sessionProvider.name != null) {
          _nameController.text = sessionProvider.name!;
        }
        if (sessionProvider.phone != null) {
          _phoneController.text = sessionProvider.phone!;
        }
      });
      return true;
    }
    return false;
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

  @override
  Widget build(BuildContext context) {
    // Get current user for filtering
    final sessionProvider =
        provider.Provider.of<UserSessionProvider>(context, listen: false);
    final currentUserId = sessionProvider.email ?? '';

    final statsAsync = ref.watch(supabase_providers.supabaseTaskStatsProvider);

    // Wrap with Consumer to listen to UserSessionProvider changes
    return provider.Consumer<UserSessionProvider>(
      builder: (context, sessionProvider, child) {
        // Reload session data when provider notifies
        if (sessionProvider.email != null &&
            sessionProvider.email != _emailController.text) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _emailController.text = sessionProvider.email!;
              if (sessionProvider.name != null) {
                _nameController.text = sessionProvider.name!;
              }
              if (sessionProvider.phone != null) {
                _phoneController.text = sessionProvider.phone!;
              }
            });
          });
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: _isEditing ? _pickAvatar : null,
                                child: Hero(
                                  tag: 'profile_avatar',
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _avatarPath != null
                                          ? Image.file(
                                              File(_avatarPath!),
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return _buildDefaultAvatar();
                                              },
                                            )
                                          : _buildDefaultAvatar(),
                                    ),
                                  ),
                                ),
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _nameController.text,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _emailController.text,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.check : Icons.edit,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_isEditing) {
                        _saveProfile();
                      }
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                  ),
                ],
              ),

              // Stats Cards (filtered by current user)
              SliverToBoxAdapter(
                child: statsAsync.when(
                  data: (statsMap) {
                    // Convert Map to TaskStats
                    final stats = TaskStats(
                      total: statsMap['total'] ?? 0,
                      completed: statsMap['completed'] ?? 0,
                      pending: statsMap['pending'] ?? 0,
                      highPriority: statsMap['high_priority'] ?? 0,
                    );

                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                              'Total', stats.total.toString(), Colors.blue),
                          _buildStatItem(
                              'Done', stats.completed.toString(), Colors.green),
                          _buildStatItem('Pending', stats.pending.toString(),
                              Colors.orange),
                        ],
                      ),
                    );
                  },
                  loading: () => Container(
                    margin: const EdgeInsets.all(16),
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              // Profile Info Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Information',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.person,
                        title: 'Full Name',
                        controller: _nameController,
                        enabled: _isEditing,
                      ),
                      _buildInfoCard(
                        icon: Icons.email,
                        title: 'Email',
                        controller: _emailController,
                        enabled: _isEditing,
                      ),
                      _buildInfoCard(
                        icon: Icons.phone,
                        title: 'Phone',
                        controller: _phoneController,
                        enabled: _isEditing,
                      ),
                      _buildInfoCard(
                        icon: Icons.location_on,
                        title: 'Location',
                        controller: _locationController,
                        enabled: _isEditing,
                      ),
                      _buildBioCard(),
                    ],
                  ),
                ),
              ),

              // Settings Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsTile(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'Task reminders and updates',
                        trailing: Switch(
                          value: _notifications,
                          onChanged: (value) {
                            setState(() {
                              _notifications = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.dark_mode,
                        title: 'Dark Mode',
                        subtitle: 'Toggle dark theme',
                        trailing: Switch(
                          value: _darkMode,
                          onChanged: (value) {
                            setState(() {
                              _darkMode = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.security,
                        title: 'Security',
                        subtitle: 'Password and authentication',
                        onTap: () {
                          context.push('/security');
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.help,
                        title: 'Help Center',
                        subtitle: 'FAQs and support',
                        onTap: () {
                          context.push('/help');
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.privacy_tip,
                        title: 'Privacy Policy',
                        subtitle: 'Data usage and privacy',
                        onTap: () {
                          context.push('/privacy');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Logout Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }

  /// Build default avatar
  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: 50,
        color: Colors.grey.shade400,
      ),
    );
  }

  /// Build stat item
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Build info card
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    bool enabled = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                enabled
                    ? TextField(
                        controller: controller,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      )
                    : Text(
                        controller.text,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build bio card
  Widget _buildBioCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Bio',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isEditing
              ? TextField(
                  controller: _bioController,
                  maxLines: 3,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tell us about yourself...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey),
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
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                )
              : Text(
                  _bioController.text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
        ],
      ),
    );
  }

  /// Build settings tile
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  /// Pick avatar image
  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage =
            await File(pickedFile.path).copy('${appDir.path}/$fileName');

        setState(() {
          _avatarPath = savedImage.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Save profile to SharedPreferences
  Future<void> _saveProfile() async {
    print('🔥 === OLD PROFILE SCREEN: _saveProfile START ===');
    print('🔥 Name: "${_nameController.text.trim()}"');
    print('🔥 Email: "${_emailController.text.trim()}"');
    print('🔥 Phone: "${_phoneController.text.trim()}"');
    print('🔥 Location: "${_locationController.text.trim()}"');
    print('🔥 Bio: "${_bioController.text.trim()}"');
    print('🔥 Avatar: "$_avatarPath"');
    print('🔥 Dark Mode: $_darkMode');
    print('🔥 Notifications: $_notifications');

    try {
      // Validate email format
      if (!_emailController.text.contains('@')) {
        throw Exception('Please enter a valid email address');
      }

      final prefs = await SharedPreferences.getInstance();
      print('🔥 Saving to SharedPreferences...');

      // Save profile data
      await prefs.setString('profile_name', _nameController.text.trim());
      await prefs.setString('profile_email', _emailController.text.trim());
      await prefs.setString('profile_phone', _phoneController.text.trim());
      await prefs.setString(
          'profile_location', _locationController.text.trim());
      await prefs.setString('profile_bio', _bioController.text.trim());
      if (_avatarPath != null) {
        await prefs.setString('profile_avatar', _avatarPath!);
      }
      await prefs.setBool('profile_dark_mode', _darkMode);
      await prefs.setBool('profile_notifications', _notifications);

      print('🔥 SharedPreferences saved, calling Supabase update...');

      // Also update Supabase database
      try {
        final supabaseUserService =
            SupabaseUserService(SupabaseUserRepository());
        print('🔥 Calling Supabase update with location and bio...');

        await supabaseUserService.updateUserProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          avatarUrl: _avatarPath,
          themeMode: _darkMode ? 'dark' : 'light',
          notificationsEnabled: _notifications,
        );
        print('🔥 Supabase update completed!');
      } catch (supabaseError) {
        print('🔥 Supabase update failed: $supabaseError');
        // Continue even if Supabase fails - SharedPreferences saved
      }

      // Update session provider with new profile data
      final sessionProvider =
          provider.Provider.of<UserSessionProvider>(context, listen: false);
      await sessionProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save profile: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _saveProfile,
            ),
          ),
        );
      }
    }
  }

  /// Load profile from SharedPreferences
  /// Only loads fields that are not already set from session
  Future<void> _loadProfile(bool hasSessionData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (mounted) {
        setState(() {
          // Only load from SharedPreferences if session data wasn't available
          if (!hasSessionData) {
            _nameController.text =
                prefs.getString('profile_name') ?? 'Chinit Hem';
            _emailController.text =
                prefs.getString('profile_email') ?? 'chinithem81@gmail.com';
            _phoneController.text =
                prefs.getString('profile_phone') ?? '+855 011 311 161';
          }
          // These fields are always loaded from SharedPreferences (not in session)
          _locationController.text =
              prefs.getString('profile_location') ?? 'Phnom Penh, Cambodia';
          _bioController.text = prefs.getString('profile_bio') ??
              'Flutter developer. Love building beautiful and productive apps!';
          _avatarPath = prefs.getString('profile_avatar');
          _darkMode = prefs.getBool('profile_dark_mode') ?? false;
          _notifications = prefs.getBool('profile_notifications') ?? true;
        });
      }
    } catch (e) {
      // Use default values if loading fails
      debugPrint('Failed to load profile: $e');
    }
  }

  /// Confirm logout
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Clear user session
      final sessionProvider =
          provider.Provider.of<UserSessionProvider>(context, listen: false);
      await sessionProvider.clearSession();

      // Show logout message and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged out successfully',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
      context.go('/login');
    }
  }
}
