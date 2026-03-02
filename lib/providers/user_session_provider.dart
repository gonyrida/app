import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UserSessionProvider - Caches user login info
/// Stores: email, name, phone from login/signup
class UserSessionProvider extends ChangeNotifier {
  String? _email;
  String? _name;
  String? _phone;
  bool _isLoggedIn = false;

  String? get email => _email;
  String? get name => _name;
  String? get phone => _phone;
  bool get isLoggedIn => _isLoggedIn;

  UserSessionProvider() {
    _loadSession();
  }

  /// Load saved session from SharedPreferences
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _email = prefs.getString('user_email');
    _name = prefs.getString('user_name');
    _phone = prefs.getString('user_phone');
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    notifyListeners();
  }

  /// Clear all user data from SharedPreferences
  Future<void> _clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('is_logged_in');
  }

  /// Save user session after login/signup
  Future<void> saveSession({
    required String email,
    String? name,
    String? phone,
  }) async {
    // Clear any previous user data first
    await _clearAllUserData();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    if (name != null) await prefs.setString('user_name', name);
    if (phone != null) await prefs.setString('user_phone', phone);
    await prefs.setBool('is_logged_in', true);

    _email = email;
    _name = name;
    _phone = phone;
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Clear session on logout
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.setBool('is_logged_in', false);

    _email = null;
    _name = null;
    _phone = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  /// Update profile info
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      await prefs.setString('user_name', name);
      _name = name;
    }
    if (phone != null) {
      await prefs.setString('user_phone', phone);
      _phone = phone;
    }
    if (email != null) {
      await prefs.setString('user_email', email);
      _email = email;
    }
    notifyListeners();
  }
}
