import 'package:dio/dio.dart';
import 'api_error_model.dart';

class ApiResult {
  final bool isSuccess;
  final Response? data;
  final ApiErrorModel? error;

  ApiResult._({required this.isSuccess, required this.data, this.error});

  factory ApiResult.success(Response data) {
    return ApiResult._(data: data, isSuccess: true, error: null);
  }

  factory ApiResult.failure(ApiErrorModel error) {
    return ApiResult._(error: error, data: null, isSuccess: false);
  }

  Map<String, dynamic> toJson() => {'data': data, 'error': error?.toJson()};

  dynamic when({
    required Function(dynamic data) success,
    required Function(ApiErrorModel error) failure,
  }) async {
    if (data != null) {
      return success(data);
    } else {
      return failure(error!);
    }
  }
}
