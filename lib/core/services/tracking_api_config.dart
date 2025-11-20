class TrackingApiConfig {
  // Production server URL
  static const String baseUrl = 'https://nowshipping.co';
  static const String apiBaseUrl = '$baseUrl/api/v1/courier';
  
  // Endpoints
  static const String updateLocation = '$apiBaseUrl/location';
  static const String locationPreferences = '$apiBaseUrl/location/preferences';
  static const String locationStatus = '$apiBaseUrl/location/status';
  
  // Socket.IO URL
  static String get socketUrl => baseUrl;
  
  // Update intervals - ALL set to 25 seconds
  static const int updateIntervalSeconds = 25; // 25 seconds (foreground timer)
  static const int backgroundUpdateSeconds = 25; // 25 seconds (background)
  static const int distanceFilterMeters = 10; // 10 meters
}


