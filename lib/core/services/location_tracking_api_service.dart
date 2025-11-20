import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tracking_api_config.dart';

// Provider for location tracking API service
final locationTrackingApiServiceProvider = Provider<LocationTrackingApiService>((ref) {
  return LocationTrackingApiService();
});

class LocationTrackingApiService {
  // Get stored token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Get headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Update location
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(TrackingApiConfig.updateLocation),
        headers: headers,
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update location',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Update location tracking preferences
  Future<Map<String, dynamic>> updateLocationPreferences({
    required bool isEnabled,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(TrackingApiConfig.locationPreferences),
        headers: headers,
        body: jsonEncode({
          'isEnabled': isEnabled,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update preferences',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Get location status
  Future<Map<String, dynamic>> getLocationStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(TrackingApiConfig.locationStatus),
        headers: headers,
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'isLocationTrackingEnabled': data['isLocationTrackingEnabled'],
          'currentLocation': data['currentLocation'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get status',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}


