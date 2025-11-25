import 'dart:convert';
import 'package:http/http.dart' as http;

/// Utility class for parsing and converting technical errors to user-friendly messages
class ErrorMessageParser {
  /// Common exception prefixes to remove from error messages
  static final List<String> _exceptionPrefixes = [
    'Exception:',
    'Error:',
    'Failed:',
    'Exception',
    'Error',
    'HttpException:',
    'SocketException:',
    'FormatException:',
    'TimeoutException:',
  ];

  /// Parse error from HTTP response and convert to user-friendly message
  /// 
  /// [response] - The HTTP response object
  /// [defaultMessage] - Default message if parsing fails
  /// 
  /// Returns a user-friendly error message
  static String parseHttpError(http.Response? response, {String? defaultMessage}) {
    if (response == null) {
      return defaultMessage ?? 'An unexpected error occurred';
    }

    final statusCode = response.statusCode;
    final body = response.body;

    // Try to extract message from response body
    String? extractedMessage;
    try {
      if (body.isNotEmpty) {
        final jsonData = jsonDecode(body);
        if (jsonData is Map<String, dynamic>) {
          // Try common error message fields
          extractedMessage = jsonData['message'] as String? ??
              jsonData['error'] as String? ??
              jsonData['errors'] as String? ??
              jsonData['error_message'] as String?;
          
          // Handle validation errors (array of errors)
          if (extractedMessage == null && jsonData['errors'] != null) {
            final errors = jsonData['errors'];
            if (errors is List && errors.isNotEmpty) {
              extractedMessage = errors.first.toString();
            } else if (errors is Map) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                extractedMessage = firstError.first.toString();
              } else if (firstError is String) {
                extractedMessage = firstError;
              }
            }
          }
        }
      }
    } catch (e) {
      // If JSON parsing fails, use raw body if it's not too long
      if (body.length < 200) {
        extractedMessage = body;
      }
    }

    // Get status code specific message
    final statusMessage = _getStatusMessage(statusCode, extractedMessage);

    // Clean up the message
    return _cleanMessage(statusMessage ?? defaultMessage ?? 'An error occurred');
  }

  /// Parse error from exception and convert to user-friendly message
  /// 
  /// [error] - The exception/error object
  /// [defaultMessage] - Default message if parsing fails
  /// 
  /// Returns a user-friendly error message
  static String parseException(dynamic error, {String? defaultMessage}) {
    if (error == null) {
      return defaultMessage ?? 'An unexpected error occurred';
    }

    String errorString = error.toString();

    // Handle specific exception types
    if (errorString.contains('SocketException') || 
        errorString.contains('Failed host lookup') ||
        errorString.contains('Network is unreachable')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (errorString.contains('TimeoutException') || 
        errorString.contains('Timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('FormatException') || 
        errorString.contains('Invalid JSON')) {
      return 'Invalid response from server. Please try again.';
    }

    if (errorString.contains('HttpException')) {
      // Try to extract status code from HttpException
      final statusMatch = RegExp(r'\d{3}').firstMatch(errorString);
      if (statusMatch != null) {
        final statusCode = int.tryParse(statusMatch.group(0) ?? '');
        if (statusCode != null) {
          return _getStatusMessage(statusCode, null) ?? _cleanMessage(errorString);
        }
      }
    }

    // Try to extract HTTP status code from error message
    final statusCodeMatch = RegExp(r'\b(400|401|403|404|500|502|503|504)\b').firstMatch(errorString);
    if (statusCodeMatch != null) {
      final statusCode = int.tryParse(statusCodeMatch.group(0) ?? '');
      if (statusCode != null) {
        return _getStatusMessage(statusCode, null) ?? _cleanMessage(errorString);
      }
    }

    // Try to extract JSON error message from error string
    try {
      final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(errorString);
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0) ?? '{}');
        if (jsonData is Map<String, dynamic>) {
          final message = jsonData['message'] as String? ?? 
                         jsonData['error'] as String?;
          if (message != null) {
            return _cleanMessage(message);
          }
        }
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }

    return _cleanMessage(errorString, defaultMessage: defaultMessage);
  }

  /// Get user-friendly message based on HTTP status code
  static String? _getStatusMessage(int statusCode, String? extractedMessage) {
    switch (statusCode) {
      case 400:
        return extractedMessage ?? 
               'Invalid request. Please check your input and try again.';
      
      case 401:
        return 'Your session has expired. Please login again.';
      
      case 403:
        return extractedMessage ?? 
               'You do not have permission to perform this action.';
      
      case 404:
        return extractedMessage ?? 
               'The requested resource was not found.';
      
      case 408:
        return 'Request timed out. Please try again.';
      
      case 409:
        return extractedMessage ?? 
               'A conflict occurred. Please try again.';
      
      case 422:
        return extractedMessage ?? 
               'Validation error. Please check your input.';
      
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      
      case 500:
        return 'Server error. Please try again later.';
      
      case 502:
        return 'Bad gateway. Please try again later.';
      
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      
      case 504:
        return 'Gateway timeout. Please try again.';
      
      default:
        return extractedMessage;
    }
  }

  /// Clean error message by removing technical prefixes and formatting
  static String _cleanMessage(String message, {String? defaultMessage}) {
    if (message.isEmpty) {
      return defaultMessage ?? 'An error occurred';
    }

    String cleaned = message.trim();

    // Remove exception prefixes
    for (final prefix in _exceptionPrefixes) {
      if (cleaned.startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length).trim();
        // Remove leading colon if present
        if (cleaned.startsWith(':')) {
          cleaned = cleaned.substring(1).trim();
        }
      }
    }

    // Remove nested exception patterns (e.g., "Exception: Error: message")
    for (final prefix in _exceptionPrefixes) {
      final pattern = RegExp('$prefix\\s*:', caseSensitive: false);
      cleaned = cleaned.replaceAll(pattern, '').trim();
    }

    // Remove HTTP status code patterns at the start
    cleaned = cleaned.replaceFirst(RegExp(r'^\d{3}\s*[-:]?\s*'), '').trim();

    // Remove common technical prefixes
    final technicalPrefixes = [
      'Failed to',
      'Error',
      'Exception',
      'API',
      'HttpException',
    ];

    for (final prefix in technicalPrefixes) {
      if (cleaned.toLowerCase().startsWith(prefix.toLowerCase())) {
        // Check if there's a colon or dash after the prefix
        final pattern = RegExp('^$prefix\\s*[-:]\\s*', caseSensitive: false);
        if (pattern.hasMatch(cleaned)) {
          cleaned = cleaned.replaceFirst(pattern, '').trim();
        }
      }
    }

    // Capitalize first letter
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    // If message is too technical or empty, use default
    if (cleaned.isEmpty || 
        cleaned.length < 3 || 
        cleaned.toLowerCase().contains('exception') ||
        cleaned.toLowerCase().contains('http://') ||
        cleaned.toLowerCase().contains('https://')) {
      return defaultMessage ?? 'An error occurred';
    }

    return cleaned;
  }

  /// Parse error from both response and exception (comprehensive parsing)
  /// 
  /// [response] - The HTTP response object (optional)
  /// [error] - The exception/error object (optional)
  /// [defaultMessage] - Default message if parsing fails
  /// 
  /// Returns a user-friendly error message
  static String parse({
    http.Response? response,
    dynamic error,
    String? defaultMessage,
  }) {
    // Prioritize response parsing if available
    if (response != null) {
      final parsed = parseHttpError(response, defaultMessage: defaultMessage);
      if (parsed != defaultMessage) {
        return parsed;
      }
    }

    // Fall back to exception parsing
    if (error != null) {
      return parseException(error, defaultMessage: defaultMessage);
    }

    return defaultMessage ?? 'An unexpected error occurred';
  }
}

