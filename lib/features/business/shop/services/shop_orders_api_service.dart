import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/error_message_parser.dart';
import '../models/shop_order.dart';

class ShopOrdersApiService {
  static const String baseUrl = 'https://nowshipping.co/api/v1';

  /// Get authentication headers
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Cache-Control': 'no-cache',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch all shop orders
  static Future<List<ShopOrder>> fetchShopOrders({String? status}) async {
    var url = Uri.parse('$baseUrl/courier/shop/orders');
    
    // Add status query parameter if provided
    if (status != null && status.isNotEmpty) {
      url = Uri.parse('$baseUrl/courier/shop/orders?status=$status');
    }
    
    final headers = await _authHeaders();

    print('🛍️ [API] Fetching shop orders${status != null ? ' (status: $status)' : ''}');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final orders = data.map((json) => ShopOrder.fromJson(json as Map<String, dynamic>)).toList();
        
        print('✅ Successfully fetched ${orders.length} shop orders');
        return orders;
      } else {
        print('❌ Failed to fetch shop orders: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to fetch shop orders',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error fetching shop orders: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch shop orders',
      );
      throw Exception(errorMessage);
    }
  }

  /// Fetch shop order details by ID
  static Future<ShopOrder> fetchShopOrderDetails(String orderId) async {
    final url = Uri.parse('$baseUrl/courier/shop/orders/$orderId');
    final headers = await _authHeaders();

    print('🛍️ [API] Fetching shop order details: $orderId');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        
        print('✅ Successfully fetched shop order details: $orderId');
        return ShopOrder.fromJson(data);
      } else {
        print('❌ Failed to fetch shop order details: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to fetch shop order details',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error fetching shop order details: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch shop order details',
      );
      throw Exception(errorMessage);
    }
  }

  /// Update shop order status
  static Future<Map<String, dynamic>> updateShopOrderStatus({
    required String orderId,
    required String status,
    String? location,
    String? notes,
  }) async {
    final url = Uri.parse('$baseUrl/courier/shop/orders/$orderId/status');
    final headers = await _authHeaders();

    final body = <String, dynamic>{
      'status': status,
    };

    if (location != null && location.isNotEmpty) {
      body['location'] = location;
    }

    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    print('🔄 [API] Updating shop order status: $orderId');
    print('📍 URL: $url');
    print('📋 Headers: $headers');
    print('📤 Request Body: ${jsonEncode(body)}');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Shop order status updated successfully: $orderId');
        return data;
      } else {
        print('❌ Failed to update shop order status: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to update shop order status',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error updating shop order status: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to update shop order status',
      );
      throw Exception(errorMessage);
    }
  }
}
