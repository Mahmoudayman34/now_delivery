import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/custom_notifications.dart';
import '../../main/widgets/main_layout.dart';
import '../../../core/services/firebase_messaging_service.dart';

class AuthService {
  static const String baseUrl = 'https://nowshipping.co/api/v1';

  static Future<bool> loginCourier(BuildContext context, String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/courier-login');
    debugPrint('Attempting courier login with email: $email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Raw response: ${response.body}');

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final token = data['token'];
        final userData = data['user'];
        final prefs = await SharedPreferences.getInstance();
        
        debugPrint('💾 Saving authentication data...');
        
        // Save for backward compatibility (existing code)
        await prefs.setString('token', token);
        await prefs.setString('userRole', userData['role']);
        await prefs.setString('userEmail', userData['email']);
        await prefs.setString('userName', userData['name']);
        
        // Save for AuthNotifier (persistent login state)
        await prefs.setString('auth_token', token);
        debugPrint('✅ Saved auth_token: $token');
        
        // Create user data structure compatible with User model
        final userDataJson = {
          'id': userData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'email': userData['email'] ?? '',
          'name': userData['name'] ?? '',
          'phone': userData['phone'],
          'avatar': userData['avatar'],
          'role': userData['role'],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        final userDataJsonString = jsonEncode(userDataJson);
        await prefs.setString('user_data', userDataJsonString);
        debugPrint('✅ Saved user_data: $userDataJsonString');
        
        // Verify the data was saved
        final savedToken = prefs.getString('auth_token');
        final savedUserData = prefs.getString('user_data');
        debugPrint('🔍 Verification - Token saved: ${savedToken != null}');
        debugPrint('🔍 Verification - User data saved: ${savedUserData != null}');

        // Update FCM token on login for multi-device support
        try {
          final firebaseMessaging = FirebaseMessagingService();
          if (firebaseMessaging.isInitialized) {
            await firebaseMessaging.updateTokenOnLogin(token);
            debugPrint('✅ FCM token updated on login');
          } else {
            await firebaseMessaging.initialize();
            if (firebaseMessaging.isInitialized) {
              await firebaseMessaging.updateTokenOnLogin(token);
              debugPrint('✅ FCM token updated on login (after initialization)');
            }
          }
        } catch (e) {
          debugPrint('⚠️  Failed to update FCM token on login: $e');
          // Continue with login even if FCM update fails
        }

        // Show success notification
        CustomNotification.showSuccess(
          context,
          title: 'Login Successful',
          message: data['message'] ?? 'Welcome back! You have successfully logged in.',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
        return true;
      } else {
        // Show error notification
        CustomNotification.showError(
          context,
          title: 'Login Failed',
          message: data['message'] ?? 'Invalid credentials. Please try again.',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      // Show error notification with retry option
      CustomNotification.showError(
        context,
        title: 'Connection Error',
        message: 'Something went wrong. Please check your internet connection.',
      );
      return false;
    }
  }
}
