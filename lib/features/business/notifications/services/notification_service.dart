import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'https://nowshipping.co/api/v1';

  /// Get auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        debugPrint('⚠️  No auth token available');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/courier/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      debugPrint('📱 Get notifications response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Handle the courier API response format
        if (jsonData is Map && jsonData['success'] == true) {
          if (jsonData.containsKey('notifications')) {
            final notificationsList = jsonData['notifications'] as List;
            return notificationsList
                .map((json) => NotificationModel.fromJson(json))
                .toList();
          }
        }
        
        debugPrint('⚠️  Unexpected response format or failed request');
        return [];
      } else {
        debugPrint('❌ Failed to get notifications: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error getting notifications: $e');
      return [];
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((notification) => !notification.isRead).length;
    } catch (e) {
      debugPrint('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read (Client-side only - no API endpoint available)
  Future<bool> markAsRead(String notificationId) async {
    // Note: The courier API does not provide a mark-as-read endpoint
    // This is handled client-side only for UI purposes
    debugPrint('⚠️  Mark as read: No API endpoint available for couriers');
    return true;
  }

  /// Mark all notifications as read (Client-side only - no API endpoint available)
  Future<bool> markAllAsRead() async {
    // Note: The courier API does not provide a mark-all-as-read endpoint
    // This is handled client-side only for UI purposes
    debugPrint('⚠️  Mark all as read: No API endpoint available for couriers');
    return true;
  }

  /// Delete notification (Not available in courier API)
  Future<bool> deleteNotification(String notificationId) async {
    // Note: The courier API does not provide a delete endpoint for notifications
    debugPrint('⚠️  Delete notification: No API endpoint available for couriers');
    return false;
  }
}

