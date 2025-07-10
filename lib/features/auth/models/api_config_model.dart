import 'package:equatable/equatable.dart';

class ApiConfigModel extends Equatable {
  final String port;
  final String baseUrl;
  final String dbName;

  const ApiConfigModel({
    required this.port,
    required this.baseUrl,
    required this.dbName,
  });

  // The copyWith function
  ApiConfigModel copyWith({
    String? port,
    String? baseUrl,
    String? dbName,
    String? printIp,
    String? printPort,
  }) {
    return ApiConfigModel(
      port: port ?? this.port,
      baseUrl: baseUrl ?? this.baseUrl,
      dbName: dbName ?? this.dbName,
    );
  }

  @override
  List<Object?> get props => [port, baseUrl, dbName];
}
