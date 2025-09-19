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
      // Hardcoded credentials validation
      const String validEmail = 'mahmouddayman186@gmail.com';
      const String validPassword = '12345678';
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Check if provided credentials match the hardcoded ones
      if (email.trim().toLowerCase() != validEmail.toLowerCase() || password != validPassword) {
        state = const AuthState.error('Invalid email or password. Please check your credentials.');
        return;
      }
      
      // Successful login response for valid credentials
      final mockUser = User(
        id: '1',
        email: validEmail,
        name: 'Mahmoud Dayman',
        phone: '+1234567890',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      const mockToken = 'mock_jwt_token_12345';

      // Store auth data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, mockToken);
      await prefs.setString(_userKey, jsonEncode(mockUser.toJson()));

      state = AuthState.authenticated(user: mockUser, token: mockToken);
    } catch (e) {
      state = AuthState.error('Login failed: $e');
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = const AuthState.loading();

    try {
      // TODO: Replace with actual API endpoint
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Mock successful registration response
      final mockUser = User(
        id: '1',
        email: email,
        name: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      const mockToken = 'mock_jwt_token_12345';

      // Store auth data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, mockToken);
      await prefs.setString(_userKey, jsonEncode(mockUser.toJson()));

      state = AuthState.authenticated(user: mockUser, token: mockToken);
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
      // TODO: Replace with actual API endpoint to delete user account
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
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
    if (state.user == null) return;
    
    state = const AuthState.loading();

    try {
      // TODO: Replace with actual API endpoint
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      final updatedUser = state.user!.copyWith(
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
        token: state.token!,
      );
    } catch (e) {
      state = AuthState.error('Profile update failed: $e');
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
