part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoadingAuthState extends LoginState {}

final class SuccessToLoginState extends LoginState {}

final class FailedToLoginState extends LoginState {
  final String message;
  const FailedToLoginState({required this.message});
  @override
  List<Object> get props => [message];
}
