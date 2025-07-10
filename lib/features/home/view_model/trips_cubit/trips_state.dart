part of 'trips_cubit.dart';

abstract class TripsState extends Equatable {
  const TripsState();

  @override
  List<Object?> get props => [];
}

class TripsInitial extends TripsState {}

class TripsLoading extends TripsState {}

class TripsLoaded extends TripsState {
  final List<Trip> allTrips;
  final List<Trip> filteredTrips;
  final String selectedStatus;
  final String searchQuery;

  const TripsLoaded({
    required this.allTrips,
    required this.filteredTrips,
    required this.selectedStatus,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [
    allTrips,
    filteredTrips,
    selectedStatus,
    searchQuery,
  ];
}

class TripsError extends TripsState {
  final String message;

  const TripsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TripCreating extends TripsState {}

class TripCreated extends TripsState {
  final Trip trip;

  const TripCreated({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripCreationError extends TripsState {
  final String message;

  const TripCreationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TripUpdating extends TripsState {}

class TripUpdated extends TripsState {
  final Trip trip;

  const TripUpdated({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripUpdateError extends TripsState {
  final String message;

  const TripUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
