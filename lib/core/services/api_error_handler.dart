// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'api_error_model.dart';

class ResponseMessage {
  static String noContent = "Aucun contenu";
  static String badRequest = "Mauvaise requête";
  static String unauthorized = "Non autorisé";
  static String forbidden = "Interdit";
  static String internalServerError = "Erreur interne du serveur";
  static String notFound = "Non trouvé";

  // Local status code
  static String connectTimeout = "Délai de connexion dépassé";
  static String cancel = "Annulé";
  static String receiveTimeout = "Délai de réception dépassé";
  static String sendTimeout = "Délai d'envoi dépassé";
  static String cacheError = "Erreur de cache";
  static String noInternetConnection = "Pas de connexion Internet";
  static String defaultError =
      "Un problème est survenu, veuillez réessayer plus tard";

  // Local database errors
  static String noUserFound = "Aucun utilisateur trouvé";
  static String noTourFound = "Aucun tournee trouvé";
  static String noHistoriesFound = "Aucun historique trouvé";
  static String loginError =
      "E-mail ou mot de passe incorrect, veuillez réessayer";
  static String emailRequired = "Adresse e-mail requise";
  static String passwordRequired = "Mot de passe requis";
  static String noCollection = "Aucune collection trouvée";
}

class ErrorHandler {
  static ApiErrorModel handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return ApiErrorModel(
            code: 0,
            message: ResponseMessage.connectTimeout,
          );
        case DioExceptionType.sendTimeout:
          return ApiErrorModel(code: 0, message: ResponseMessage.sendTimeout);
        case DioExceptionType.receiveTimeout:
          return ApiErrorModel(
            code: 0,
            message: ResponseMessage.receiveTimeout,
          );
        case DioExceptionType.badCertificate:
          return ApiErrorModel(code: 0, message: ResponseMessage.defaultError);
        case DioExceptionType.badResponse:
          return ApiErrorModel(code: 0, message: ResponseMessage.badRequest);
        case DioExceptionType.unknown:
          return ApiErrorModel(code: 0, message: ResponseMessage.defaultError);
        case DioExceptionType.cancel:
          return ApiErrorModel(code: 0, message: ResponseMessage.cancel);
        case DioExceptionType.connectionError:
          return ApiErrorModel(
            code: 0,
            message: ResponseMessage.noInternetConnection,
          );
      }
    } else {
      return ApiErrorModel(code: 0, message: ResponseMessage.defaultError);
    }
  }
}
