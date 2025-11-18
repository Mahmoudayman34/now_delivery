import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://nowshipping.co/api/v1';

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  static Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final headers = await _authHeaders();
    final response = await http.get(_uri(path, query), headers: headers);
    _throwIfFailed(response);
    return jsonDecode(response.body);
  }

  static void _throwIfFailed(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('API ${res.request?.url} failed: ${res.statusCode} ${res.body}');
    }
  }
}


