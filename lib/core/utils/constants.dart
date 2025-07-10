class Consts {
  // API endpoints
  static const String login = '/web/session/authenticate';
  static const String logout = '/web/session/logout';

  // Database
  static const String dbName = 'myapp_db';

  // Session
  static const String sessionTimeout = '3600'; // 1 hour in seconds
}

class ResponseMessage {
  static const String defaultError =
      'Une erreur s\'est produite. Veuillez réessayer.';
  static const String networkError =
      'Erreur de connexion réseau. Vérifiez votre connexion internet.';
  static const String timeoutError =
      'Délai d\'attente dépassé. Veuillez réessayer.';
  static const String serverError =
      'Erreur du serveur. Veuillez réessayer plus tard.';
  static const String authenticationError =
      'Identifiants incorrects. Veuillez vérifier vos informations.';
  static const String sessionExpired =
      'Votre session a expiré. Veuillez vous reconnecter.';
}
