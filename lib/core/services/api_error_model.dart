class ApiErrorModel {
  int code;
  String message;

  ApiErrorModel({required this.code, required this.message});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      code: json['code'] ?? json['status'] ?? 0,
      message: json['message'] ?? 'Unknown error',
    );
  }

  Map<String, dynamic> toJson() => {'code': code, 'message': message};

  @override
  String toString() => message;
}
