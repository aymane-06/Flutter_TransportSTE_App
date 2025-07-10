part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserModel user;
  final DashboardStatsModel dashboardStats;

  const HomeLoaded({required this.user, required this.dashboardStats});

  @override
  List<Object?> get props => [user, dashboardStats];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserProfileUpdating extends HomeState {}

class UserProfileUpdated extends HomeState {}

class UserProfileUpdateError extends HomeState {
  final String message;

  const UserProfileUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
