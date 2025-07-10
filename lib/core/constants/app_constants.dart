class AppConstants {
  // App Information
  static const String appName = 'STE Transport';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.ste-transport.com';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Transport Constants
  static const List<String> vehicleTypes = [
    'Camion',
    'Autobus',
    'Fourgon',
    'Remorque',
  ];

  static const List<String> tripStatuses = [
    'Planifié',
    'En cours',
    'Terminé',
    'Annulé',
    'En retard',
  ];

  static const List<String> countries = [
    'Maroc',
    'France',
    'Espagne',
    'Allemagne',
  ];

  // Error Messages
  static const String networkError = 'Erreur de connexion réseau';
  static const String serverError = 'Erreur du serveur';
  static const String unknownError = 'Erreur inconnue';
  static const String validationError = 'Erreur de validation';
}
