import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/constants.dart' as app_constants;
import '../models/user_auth_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRepo {
  Future<Either<Failure, Unit>> login(UserAuthModel user);
  bool isSessionExpired();
  Future<void> logout();
}

class AuthRepoImp extends AuthRepo {
  AuthRepoImp({
    required ApiService apiService,
    required SharedPreferences preferences,
  }) : _apiService = apiService,
       _preferences = preferences;
  final ApiService _apiService;
  final SharedPreferences _preferences;

  @override
  Future<Either<Failure, Unit>> login(UserAuthModel user) async {
    try {
      await _preferences.remove("session_id");
      String db =
          _preferences.getString("DB_NAME") ?? app_constants.Consts.dbName;

      Map params = {"db": db, "login": user.email, "password": user.password};
      var apiRes = await _apiService.post(
        app_constants.Consts.login,
        params: params,
      );

      if (!apiRes.isSuccess) {
        return Left(
          ServerFailure(
            message: apiRes.error?.message ?? ResponseMessage.defaultError,
          ),
        );
      }
      Response response = apiRes.data!;

      String cookieHeader = response.headers.toString();
      final sessionRegex = RegExp(r'session_id=([A-Za-z0-9_-]+);');
      final sessionMatch = sessionRegex.firstMatch(cookieHeader);
      if (sessionMatch == null) {
        throw Exception('Session ID not found in response cookies');
      }
      final sessionId = sessionMatch.group(1);

      if (sessionId == null) {
        throw Exception('Session ID extraction failed');
      }
      int userId = response.data['result']['uid'];

      await _preferences.setInt('user_id', userId);
      await _preferences.setString('session_id', sessionId);
      final expiresDateregex = RegExp(r'Expires=([A-Za-z, 0-9:-]+) GMT;');
      final expiresDateMatch = expiresDateregex.firstMatch(cookieHeader);
      if (expiresDateMatch != null) {
        final expiresValue = expiresDateMatch.group(1);
        if (expiresValue != null) {
          await _preferences.setString('session_expires', expiresValue);
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  bool isSessionExpired() {
    var sessionId = _preferences.getString("session_id");
    var sessionExpires = _preferences.getString("session_expires");
    if (sessionExpires == null || sessionId == null) {
      return true;
    }

    try {
      final currentTime = DateTime.now().toUtc();

      // The format from server is: "Thu, 09 Jul 2026 13:29:52"
      // Remove any " GMT" suffix if present
      String cleanDateString = sessionExpires.replaceAll(' GMT', '');

      final inputFormat = DateFormat('E, dd MMM yyyy HH:mm:ss');
      final expiresDate = inputFormat.parse(cleanDateString);

      return currentTime.isAfter(expiresDate);
    } catch (e) {
      // If we can't parse the date, consider session expired for safety
      return true;
    }
  }

  @override
  Future<void> logout() async {
    _apiService.clearSessionId();
    await _preferences.remove("session_id");
    await _preferences.remove("session_expires");
    await _preferences.remove("user_id");
  }
}
