import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/utils/error_message_parser.dart';
import '../models/pickup.dart';

class PickupsApiService {
  static const String baseUrl = 'https://nowshipping.co/api/v1';

  /// Get authentication headers with bearer token
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Cache-Control': 'no-cache',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetch all pickups for the courier
  static Future<List<Pickup>> fetchPickups() async {
    final url = Uri.parse('$baseUrl/courier/pickups');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Pickup.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to fetch pickups',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch pickups',
      );
      throw Exception(errorMessage);
    }
  }

  /// Fetch a single pickup by ID
  static Future<Pickup> fetchPickupById(String pickupId) async {
    final url = Uri.parse('$baseUrl/courier/pickups/$pickupId');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Pickup.fromJson(data);
      } else {
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to fetch pickup',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch pickup',
      );
      throw Exception(errorMessage);
    }
  }

  /// Fetch pickup details by pickup number
  static Future<Pickup> fetchPickupDetails(String pickupNumber) async {
    final url = Uri.parse('$baseUrl/courier/pickups/$pickupNumber/details');
    final headers = await _authHeaders();

    print('🚀 [API] Fetching pickup details: $pickupNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final pickupData = data['pickup'] as Map<String, dynamic>;
        
        print('✅ Successfully fetched pickup details: $pickupNumber');
        return Pickup.fromJson(pickupData);
      } else {
        print('❌ Failed to fetch pickup details: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to fetch pickup details',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error fetching pickup details: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch pickup details',
      );
      throw Exception(errorMessage);
    }
  }

  /// Scan barcode and add order to pickup
  static Future<Map<String, dynamic>> scanOrderBarcode({
    required String pickupNumber,
    required String orderNumber,
  }) async {
    final url = Uri.parse('$baseUrl/courier/pickups/$pickupNumber/orders/$orderNumber');
    final headers = await _authHeaders();

    print('📷 [API] Scanning barcode for order: $orderNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Order scanned successfully: $orderNumber');
        return data;
      } else {
        print('❌ Failed to scan order: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to scan order',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error scanning order: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to scan order',
      );
      throw Exception(errorMessage);
    }
  }

  /// Get all picked up orders for a pickup
  static Future<List<Map<String, dynamic>>> getPickedUpOrders(String pickupNumber) async {
    final url = Uri.parse('$baseUrl/courier/pickups/$pickupNumber/orders');
    final headers = await _authHeaders();

    print('📦 [API] Fetching picked up orders for pickup: $pickupNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> ordersData = data['orders'] as List<dynamic>;
        
        print('✅ Successfully fetched ${ordersData.length} picked up orders');
        return ordersData.map((order) => order as Map<String, dynamic>).toList();
      } else {
        print('❌ Failed to fetch picked up orders: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to fetch picked up orders',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error fetching picked up orders: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch picked up orders',
      );
      throw Exception(errorMessage);
    }
  }

  /// Delete an order from a pickup
  static Future<Map<String, dynamic>> deleteOrderFromPickup({
    required String pickupNumber,
    required String orderNumber,
  }) async {
    final url = Uri.parse('$baseUrl/courier/pickups/$pickupNumber/orders/$orderNumber');
    final headers = await _authHeaders();

    print('🗑️ [API] Deleting order from pickup: $orderNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.delete(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Order deleted successfully: $orderNumber');
        return data;
      } else {
        print('❌ Failed to delete order: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to delete order',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error deleting order: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to delete order',
      );
      throw Exception(errorMessage);
    }
  }

  /// Complete a pickup
  static Future<Map<String, dynamic>> completePickup(String pickupNumber) async {
    final url = Uri.parse('$baseUrl/courier/pickups/$pickupNumber/complete');
    final headers = await _authHeaders();

    print('✅ [API] Completing pickup: $pickupNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.put(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Pickup completed successfully: $pickupNumber');
        return data;
      } else {
        print('❌ Failed to complete pickup: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to complete pickup',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error completing pickup: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to complete pickup',
      );
      throw Exception(errorMessage);
    }
  }
}
