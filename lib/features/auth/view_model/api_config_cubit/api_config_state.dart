part of 'api_config_cubit.dart';

sealed class ApiConfigState extends Equatable {
  const ApiConfigState();

  @override
  List<Object> get props => [];
}

final class ApiConfigInitial extends ApiConfigState {}

final class LoadedApiConfigState extends ApiConfigState {
  final ApiConfigModel apiConfig;

  const LoadedApiConfigState({required this.apiConfig});

  @override
  List<Object> get props => [apiConfig];
}


final class SuccessToChangeApiConfigState extends ApiConfigState {}

final class SuccessToTestApiConnectionState extends ApiConfigState {
  final String message;

  const SuccessToTestApiConnectionState({required this.message});

  @override
  List<Object> get props => [message];
}

final class FailedToConnectState extends ApiConfigState {
  final String message;

  const FailedToConnectState({required this.message});

  @override
  List<Object> get props => [message];
}
