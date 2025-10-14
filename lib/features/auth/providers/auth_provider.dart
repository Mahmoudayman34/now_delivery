import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

      if (token != null && userData != null) {
        final user = User.fromJson(jsonDecode(userData));
        state = AuthState.authenticated(user: user, token: token);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error('Failed to check authentication status: $e');
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();

    try {
      // Local authentication - any non-empty credentials work
      if (email.trim().isEmpty || password.trim().isEmpty) {
        state = const AuthState.error('Please enter both email and password');
        return;
      }
      
      // Create user with provided email
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email.trim(),
        name: email.split('@').first, // Use email prefix as name
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
      state = AuthState.error('Login failed: $e');
    }
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
    state = const AuthState.loading();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);

      state = const AuthState.unauthenticated();
    } catch (e) {
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

  void clearError() {
    if (state.hasError) {
      state = const AuthState.unauthenticated();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
