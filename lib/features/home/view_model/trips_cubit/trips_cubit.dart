import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../models/trip_model.dart';
import '../../repository/home_repo.dart';

part 'trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  TripsCubit({required this.homeRepo}) : super(TripsInitial());

  final HomeRepo homeRepo;
  BuildContext? context;

  Future<void> loadTrips({String? status, String? searchQuery}) async {
    emit(TripsLoading());

    try {
      final result = await homeRepo.getUserTrips();

      result.fold((failure) => emit(TripsError(message: failure.message)), (
        trips,
      ) {
        // Filter trips if status or search query is provided
        final filteredTrips = _filterTrips(trips, status, searchQuery);
        emit(
          TripsLoaded(
            allTrips: trips,
            filteredTrips: filteredTrips,
            selectedStatus: status ?? 'Tous',
            searchQuery: searchQuery ?? '',
          ),
        );
      });
    } catch (e) {
      emit(
        TripsError(
          message: 'Une erreur est survenue lors du chargement des voyages',
        ),
      );
    }
  }

  void applyFilters({String? status, String? searchQuery}) {
    if (state is TripsLoaded) {
      final currentState = state as TripsLoaded;

      final newStatus = status ?? currentState.selectedStatus;
      final newQuery = searchQuery ?? currentState.searchQuery;

      final filteredTrips = _filterTrips(
        currentState.allTrips,
        newStatus,
        newQuery,
      );

      emit(
        TripsLoaded(
          allTrips: currentState.allTrips,
          filteredTrips: filteredTrips,
          selectedStatus: newStatus,
          searchQuery: newQuery,
        ),
      );
    }
  }

  List<Trip> _filterTrips(List<Trip> trips, String? status, String? query) {
    return trips.where((trip) {
      // Status filter
      final matchesStatus =
          status == null ||
          status == 'Tous' ||
          trip.state.name.toLowerCase() == status.toLowerCase();

      // Search query filter
      final matchesQuery =
          query == null ||
          query.isEmpty ||
          trip.name.toLowerCase().contains(query.toLowerCase()) ||
          trip.departureCity.toLowerCase().contains(query.toLowerCase()) ||
          trip.destinationCity.toLowerCase().contains(query.toLowerCase());

      return matchesStatus && matchesQuery;
    }).toList();
  }

  Future<void> refreshTrips() async {
    if (state is TripsLoaded) {
      final currentState = state as TripsLoaded;

      // Keep current filters
      final status = currentState.selectedStatus;
      final query = currentState.searchQuery;

      await loadTrips(status: status, searchQuery: query);
    } else {
      await loadTrips();
    }
  }

  // Check if a user has permission to create trips (always false now)
  bool hasCreatePermission() {
    return false;
  }

  // Method to show permission denied message when user attempts to create a trip
  void showTripCreationDenied() {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        const SnackBar(
          content: Text('Création de voyages non autorisée'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Check permission before trying to create
  Future<void> createTrip(Trip trip) async {
    if (!hasCreatePermission()) {
      showTripCreationDenied();
      return;
    }

    // This code won't be reached since hasCreatePermission always returns false
    // But keeping the structure in case permissions change in the future
    emit(TripCreating());

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    emit(TripCreationError(message: 'Création de voyages non autorisée'));
  }
}
