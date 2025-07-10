class ApiConstants {
  // Base URLs
  static const String defaultBaseUrl = 'http://localhost';
  static const String defaultPort = '10018';

  // Test endpoints
  static const String serverTestEndpoint = '/web/database/manager';

  // Authentication endpoints
  static const String loginEndpoint = '/auth/';
  static const String logoutEndpoint = '/web/session/destroy';
  static const String refreshTokenEndpoint = '/web/session/refresh';

  // User endpoints
  static const String userProfileEndpoint = '/api/res.users';
  static const String updateProfileEndpoint = '/api/res.users';

  // Transport management endpoints
  static const String tripsEndpoint = '/api/trip';
  static const String vehiclesEndpoint = '/api/fleet.vehicle';
  static const String driversEndpoint = '/api/hr.employee';
  static const String reportsEndpoint = '/api/reports';

  // Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String authorizationHeader = 'Authorization';
  static const String acceptHeader = 'Accept';

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String baseUrlKey = 'BASE_URL';
  static const String portKey = 'PORT';
  static const String sessionIdKey = 'session_id';
}
