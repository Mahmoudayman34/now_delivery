import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import '../models/auth_state.dart';
import '../models/user.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);

      print('🔍 Checking auth status...');
      print('📝 Token found: ${token != null}');
      print('👤 User data found: ${userData != null}');
      
      if (token != null) {
        print('🔑 Token: $token');
      }
      if (userData != null) {
        print('📄 User data: $userData');
      }

      if (token != null && userData != null) {
        final user = User.fromJson(jsonDecode(userData));
        print('✅ User authenticated: ${user.name} (${user.email})');
        state = AuthState.authenticated(user: user, token: token);
      } else {
        print('❌ User not authenticated - redirecting to login');
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      print('❌ Error checking auth status: $e');
      state = AuthState.error('Failed to check authentication status: $e');
    }
  }

  Future<void> login(String email, String password) async {
    // DEPRECATED: Simulated login. Use AuthService.loginCourier for production login.
    state = const AuthState.error('Use AuthService.loginCourier for login.');
  }

  Future<void> register(String name, String email, String password) async {
    state = const AuthState.loading();

    try {
      // Local registration - validate inputs
      if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
        state = const AuthState.error('Please fill in all fields');
        return;
      }
      
      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email.trim(),
        name: name.trim(),
        phone: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      const token = 'local_session_token';

      // Store auth data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      state = AuthState.authenticated(user: user, token: token);
    } catch (e) {
      state = AuthState.error('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    // Set loading state so the UI can react if needed
    state = const AuthState.loading();

    try {
      print('🔓 Starting logout...');
      final prefs = await SharedPreferences.getInstance();

      // Remove AuthNotifier keys
      final removedToken = await prefs.remove(_tokenKey);
      final removedUser = await prefs.remove(_userKey);
  print('🧹 Removed auth_token: $removedToken, user_data: $removedUser');

      // Remove legacy AuthService keys for complete logout (backwards compatibility)
      final removedLegacyToken = await prefs.remove('token');
      final removedLegacyRole = await prefs.remove('userRole');
      final removedLegacyEmail = await prefs.remove('userEmail');
      final removedLegacyName = await prefs.remove('userName');
  print('🧹 Removed legacy keys: token=$removedLegacyToken, userRole=$removedLegacyRole, userEmail=$removedLegacyEmail, userName=$removedLegacyName');

      // Completed - mark as unauthenticated
      state = const AuthState.unauthenticated();
      print('✅ Logout completed and state set to unauthenticated');
    } catch (e) {
      print('❌ Logout error: $e');
      state = AuthState.error('Logout failed: $e');
    }
  }

  Future<void> deleteAccount() async {
    state = const AuthState.loading();

    try {
      // Clear all local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored data for complete account deletion
      
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Account deletion failed: $e');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    if (state.user == null || state.token == null) return;
    
    // Save current user and token before setting loading state
    final currentUser = state.user!;
    final currentToken = state.token!;
    
    state = const AuthState.loading();

    try {
      // Update user data locally
      final updatedUser = currentUser.copyWith(
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
        updatedAt: DateTime.now(),
      );
      
      // Store updated user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
      
      state = AuthState.authenticated(
        user: updatedUser,
        token: currentToken,
      );
    } catch (e) {
      // Restore previous state on error instead of showing error state
      state = AuthState.authenticated(
        user: currentUser,
        token: currentToken,
      );
      // Re-throw so the UI can handle the error
      rethrow;
    }
  }

  /// Reload authentication state from SharedPreferences
  /// Call this after external login (e.g., AuthService.loginCourier)
  Future<void> reloadAuthState() async {
    await _checkAuthStatus();
  }

  void clearError() {
    if (state.hasError) {
      state = const AuthState.unauthenticated();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
