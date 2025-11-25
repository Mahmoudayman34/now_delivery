import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/utils/error_message_parser.dart';
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
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to fetch orders',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error fetching orders: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch orders',
      );
      throw Exception(errorMessage);
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
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to fetch order',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error fetching order: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch order',
      );
      throw Exception(errorMessage);
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
        final selectedPickupAddress = data['selectedPickupAddress'] as Map<String, dynamic>?;
        
        // Log important status fields
        print('📊 Order Status Fields:');
        print('   - orderStatus: ${orderData['orderStatus']}');
        print('   - statusLabel: ${orderData['statusLabel']}');
        print('   - statusDescription: ${orderData['statusDescription']}');
        print('   - orderNumber: ${orderData['orderNumber']}');
        if (selectedPickupAddress != null) {
          print('   - selectedPickupAddressId: ${selectedPickupAddress['addressId']}');
        }
        
        print('✅ Successfully fetched order details: $orderNumber');
        return Order.fromJson(orderData, selectedPickupAddress: selectedPickupAddress);
      } else {
        print('❌ Failed to fetch order details: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to fetch order details',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error fetching order details: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to fetch order details',
      );
      throw Exception(errorMessage);
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
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to update order status',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error updating order status: $e');
      final errorMessage = ErrorMessageParser.parseException(
        e,
        defaultMessage: 'Failed to update order status',
      );
      throw Exception(errorMessage);
    }
  }

  /// Complete order with OTP verification
  /// 
  /// Completes an order delivery. Handles different order types including standard deliveries,
  /// returns, exchanges, and cash collections. Requires OTP verification for non-return flows.
  /// 
  /// [orderNumber] - The order number to complete
  /// [otp] - The 6-digit OTP code provided by customer (required for non-return orders)
  /// [collectionReceipt] - Optional receipt/proof URL for cash collection orders
  /// [exchangePhotos] - Optional array of photo URLs for exchange orders
  /// 
  /// Returns the success message from the API
  static Future<String> completeOrder({
    required String orderNumber,
    String? otp,
    String? collectionReceipt,
    List<String>? exchangePhotos,
  }) async {
    final url = Uri.parse('$baseUrl/courier/orders/$orderNumber/complete');
    final headers = await _authHeaders();

    // Build request body - only include fields that are provided
    final Map<String, dynamic> bodyMap = {};
    
    if (otp != null && otp.isNotEmpty) {
      bodyMap['otp'] = otp;
    }
    
    if (collectionReceipt != null && collectionReceipt.isNotEmpty) {
      bodyMap['collectionReceipt'] = collectionReceipt;
    }
    
    if (exchangePhotos != null && exchangePhotos.isNotEmpty) {
      bodyMap['exchangePhotos'] = exchangePhotos;
    }

    final body = jsonEncode(bodyMap);

    print('🚀 [API] Completing order: $orderNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');
    print('📝 Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final message = responseData['message'] as String? ?? 'Order completed successfully';
          print('✅ Successfully completed order: $message');
          return message;
        } catch (e) {
          print('⚠️ Error parsing success response: $e');
          return 'Order completed successfully';
        }
      } else {
        print('❌ Failed to complete order: ${response.statusCode}');
        final errorMessage = ErrorMessageParser.parseHttpError(
          response,
          defaultMessage: 'Failed to complete order',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('💥 Error completing order: $e');
      final errorMessage = ErrorMessageParser.parse(
        response: null,
        error: e,
        defaultMessage: 'Failed to complete order',
      );
      throw Exception(errorMessage);
    }
  }

  /// Scan barcode for fast shipping order
  /// 
  /// Scans a fast shipping (express) order and marks packed/shipping/outForDelivery as completed.
  /// Moves the status to headingToCustomer for customer delivery.
  /// 
  /// [orderNumber] - The order number or Smart Flyer barcode to scan
  /// 
  /// Returns the updated order information
  static Future<Map<String, dynamic>> scanFastShippingOrder({
    required String orderNumber,
  }) async {
    final url = Uri.parse('$baseUrl/courier/orders/$orderNumber/scan-fast-shipping');
    final headers = await _authHeaders();

    print('📷 [API] Scanning fast shipping order: $orderNumber');
    print('📍 URL: $url');
    print('📋 Headers: $headers');

    try {
      final response = await http.post(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          print('✅ Successfully scanned fast shipping order: $orderNumber');
          return responseData;
        } catch (e) {
          print('⚠️ Error parsing success response: $e');
          throw Exception('Invalid response format from server');
        }
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
      final errorMessage = ErrorMessageParser.parse(
        response: null,
        error: e,
        defaultMessage: 'Failed to scan order',
      );
      throw Exception(errorMessage);
    }
  }
}
