import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrdersApiService {
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

  /// Fetch all orders for the courier
  static Future<List<Order>> fetchOrders() async {
    final url = Uri.parse('$baseUrl/courier/orders');
    final headers = await _authHeaders();

    print('🚀 [API] Fetching orders...');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Successfully fetched ${data.length} orders');
        return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        print('❌ Failed to fetch orders: ${response.statusCode}');
        throw Exception('Failed to fetch orders: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Error fetching orders: $e');
      throw Exception('Error fetching orders: $e');
    }
  }

  /// Fetch a single order by ID
  static Future<Order> fetchOrderById(String orderId) async {
    final url = Uri.parse('$baseUrl/courier/orders/$orderId');
    final headers = await _authHeaders();

    print('🚀 [API] Fetching order by ID: $orderId');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Successfully fetched order: $orderId');
        return Order.fromJson(data);
      } else {
        print('❌ Failed to fetch order: ${response.statusCode}');
        throw Exception('Failed to fetch order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Error fetching order: $e');
      throw Exception('Error fetching order: $e');
    }
  }

  /// Fetch order details by order number
  static Future<Order> fetchOrderDetails(String orderNumber) async {
    final url = Uri.parse('$baseUrl/courier/orders/$orderNumber/details');
    final headers = await _authHeaders();

    print('🚀 [API] Fetching order details: $orderNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final orderData = data['order'] as Map<String, dynamic>;
        
        // Log important status fields
        print('📊 Order Status Fields:');
        print('   - orderStatus: ${orderData['orderStatus']}');
        print('   - statusLabel: ${orderData['statusLabel']}');
        print('   - statusDescription: ${orderData['statusDescription']}');
        print('   - orderNumber: ${orderData['orderNumber']}');
        
        print('✅ Successfully fetched order details: $orderNumber');
        return Order.fromJson(orderData);
      } else {
        print('❌ Failed to fetch order details: ${response.statusCode}');
        throw Exception('Failed to fetch order details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Error fetching order details: $e');
      throw Exception('Error fetching order details: $e');
    }
  }

  /// Update order status (for customer unavailable or rejected delivery)
  /// 
  /// [orderNumber] - The order number to update
  /// [status] - Either "Unavailable" or "rejected"
  /// [reason] - The reason for the status change
  static Future<void> updateOrderStatus({
    required String orderNumber,
    required String status,
    required String reason,
  }) async {
    final url = Uri.parse('$baseUrl/courier/orders/$orderNumber/status');
    final headers = await _authHeaders();

    final body = jsonEncode({
      'status': status,
      'reason': reason,
    });

    print('🚀 [API] Updating order status: $orderNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');
    print('📝 Body: $body');

    try {
      final response = await http.put(url, headers: headers, body: body);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Successfully updated order status to: $status');
        // Success
        return;
      } else {
        print('❌ Failed to update order status: ${response.statusCode}');
        throw Exception('Failed to update order status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Error updating order status: $e');
      throw Exception('Error updating order status: $e');
    }
  }

  /// Complete order with OTP verification
  /// 
  /// [orderNumber] - The order number to complete
  /// [otp] - The OTP code provided by customer
  static Future<void> completeOrder({
    required String orderNumber,
    required String otp,
  }) async {
    // TODO: Replace with actual complete order endpoint when available
    // For now, using the status endpoint as a placeholder
    final url = Uri.parse('$baseUrl/courier/orders/$orderNumber/complete');
    final headers = await _authHeaders();

    final body = jsonEncode({
      'otp': otp,
    });

    print('🚀 [API] Completing order: $orderNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');
    print('📝 Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Successfully completed order with OTP');
        // Success
        return;
      } else {
        print('❌ Failed to complete order: ${response.statusCode}');
        throw Exception('Failed to complete order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Error completing order: $e');
      throw Exception('Error completing order: $e');
    }
  }
}
