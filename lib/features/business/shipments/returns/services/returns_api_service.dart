import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/utils/error_message_parser.dart';
import '../models/return_shipment.dart';

class ReturnsApiService {
  static const String baseUrl = 'https://nowshipping.co/api/v1';

  /// Fetch all returns for the courier
  static Future<List<ReturnShipment>> fetchReturns() async {
    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Make API request
      final response = await http.get(
        Uri.parse('$baseUrl/courier/returns'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> ordersJson = data['orders'] as List<dynamic>;
        
        return ordersJson
            .map((json) => ReturnShipment.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to load returns',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch returns',
      );
      throw Exception(errorMessage);
    }
  }

  /// Fetch a specific return by ID
  static Future<ReturnShipment> fetchReturnById(String returnId) async {
    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Make API request
      final response = await http.get(
        Uri.parse('$baseUrl/courier/returns/$returnId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ReturnShipment.fromJson(data);
      } else {
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to load return',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch return',
      );
      throw Exception(errorMessage);
    }
  }

  /// Get authentication headers
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? prefs.getString('token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Cache-Control': 'no-cache',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch return details by order number
  static Future<Map<String, dynamic>> fetchReturnDetails(String orderNumber) async {
    final url = Uri.parse('$baseUrl/courier/returns/$orderNumber/details');
    final headers = await _authHeaders();

    print('🔙 [API] Fetching return details: $orderNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body (first 1000 chars): ${response.body.substring(0, response.body.length > 1000 ? 1000 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        
        print('✅ Successfully fetched return details: $orderNumber');
        return data;
      } else {
        print('❌ Failed to fetch return details: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to fetch return details',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error fetching return details: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch return details',
      );
      throw Exception(errorMessage);
    }
  }

  /// Pickup return order by scanning barcode
  static Future<Map<String, dynamic>> pickupReturn(String orderNumber) async {
    final url = Uri.parse('$baseUrl/courier/orders/$orderNumber/pickup-return');
    final headers = await _authHeaders();

    print('🔙 [API] Picking up return: $orderNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.post(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        
        print('✅ Successfully picked up return: $orderNumber');
        print('📦 Message: ${data['message']}');
        print('📦 Next Action: ${data['nextAction']}');
        return data;
      } else {
        print('❌ Failed to pickup return: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to pickup return',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error picking up return: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to pickup return',
      );
      throw Exception(errorMessage);
    }
  }

  /// Complete return to business
  static Future<Map<String, dynamic>> completeReturnToBusiness(String orderNumber) async {
    final url = Uri.parse('$baseUrl/courier/orders/$orderNumber/complete-return-to-business');
    final headers = await _authHeaders();

    print('✅ [API] Completing return to business: $orderNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.post(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        
        print('✅ Successfully completed return to business: $orderNumber');
        print('📦 Message: ${data['message']}');
        return data;
      } else {
        print('❌ Failed to complete return to business: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to complete return to business',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error completing return to business: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to complete return to business',
      );
      throw Exception(errorMessage);
    }
  }
}
