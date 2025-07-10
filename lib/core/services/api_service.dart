import 'package:dio/dio.dart';
import 'api_error_handler.dart';
import 'api_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ApiService {
  Future<ApiResult> get(String endPoint, {Map? params});
  Future<ApiResult> post(String endPoint, {Map? params});
  Future<bool> downloadPdf(
    String endPoint, {
    required Map<String, dynamic> params,
    required String path,
  });
  void clearSessionId();
}

class ApiServiceImp extends ApiService {
  final Dio _dio;
  final SharedPreferences _preferences;

  ApiServiceImp(this._dio, this._preferences) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          String? baseUrl = _preferences.getString("BASE_URL");
          String? port = _preferences.getString("PORT");
          options.baseUrl = '$baseUrl:$port';

          String? sessionId = _preferences.getString("session_id");
          options.headers['Cookie'] = 'session_id=$sessionId';
          options.headers['Accept'] = '*/*';

          handler.next(options);
        },
        onError: (error, handler) async {
          String? errorMsg = error.toString();
          if (errorMsg.toLowerCase().contains(
            'connection closed while receiving data',
          )) {
            return handler.resolve(await _retryRequest(error.requestOptions));
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return await _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  @override
  Future<ApiResult> get(String endPoint, {Map? params}) async {
    try {
      final res = await _dio.get(
        endPoint,
        data: params != null ? {"params": params} : null,
      );
      return ApiResult.success(res);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult> post(String endPoint, {Map? params}) async {
    try {
      final res = await _dio.post(
        endPoint,
        data: params != null ? {"params": params} : null,
      );

      return ApiResult.success(res);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<bool> downloadPdf(
    String endPoint, {
    required Map<String, dynamic> params,
    required String path,
  }) async {
    try {
      FormData formData = FormData.fromMap(params);
      await _dio.download(endPoint, data: formData, (Headers headers) {
        headers.map.values;
        return path;
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  void clearSessionId() {
    _dio.options.headers.clear();
  }
}
