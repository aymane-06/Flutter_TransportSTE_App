import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';
import '../../models/dashboard_model.dart';
import '../../repository/home_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.homeRepo}) : super(HomeInitial());

  final HomeRepo homeRepo;

  Future<void> loadHomeData() async {
    emit(HomeLoading());

    try {
      // Load user profile first
      final userResult = await homeRepo.getUserProfile();

      userResult.fold((failure) => emit(HomeError(message: failure.message)), (
        user,
      ) async {
        // Load dashboard stats after getting user
        final statsResult = await homeRepo.getDashboardStats();

        statsResult.fold(
          (failure) => emit(HomeError(message: failure.message)),
          (stats) => emit(HomeLoaded(user: user, dashboardStats: stats)),
        );
      });
    } catch (e) {
      emit(HomeError(message: 'Une erreur est survenue lors du chargement'));
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    emit(UserProfileUpdating());

    final result = await homeRepo.updateUserProfile(user);
    result.fold(
      (failure) => emit(UserProfileUpdateError(message: failure.message)),
      (success) {
        emit(UserProfileUpdated());
        // Reload the home data to reflect changes
        loadHomeData();
      },
    );
  }

  Future<void> refreshData() async {
    await loadHomeData();
  }

  Future<void> loadUserTrips() async {
    // Note: This method can be used to load trips separately if needed
    // For now, trips are loaded as part of dashboard stats
    try {
      final tripsResult = await homeRepo.getUserTrips();

      tripsResult.fold(
        (failure) {
          print('Failed to load trips: ${failure.message}');
          // Could emit a specific trips error state if needed
        },
        (trips) {
          print('Successfully loaded ${trips.length} trips');
          // Could emit a trips loaded state if needed
        },
      );
    } catch (e) {
      print('Error loading trips: $e');
    }
  }
}
