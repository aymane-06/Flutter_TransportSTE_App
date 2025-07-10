import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/trip_model.dart';
import '../../view_model/trips_cubit/trips_cubit.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/trip_card.dart';
import '../widgets/trip_stat_card.dart';
import '../widgets/empty_state_widget.dart';
import '../screens/trip_details_screen.dart';

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  final TextEditingController _searchController = TextEditingController();
  late final TripsCubit _tripsCubit;

  @override
  void initState() {
    super.initState();
    _tripsCubit = getIt<TripsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tripsCubit.loadTrips();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _tripsCubit.context = context;
        return _tripsCubit;
      },
      child: BlocBuilder<TripsCubit, TripsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.grey50,
            appBar: AppBar(
              title: Text(
                'Gestion des Voyages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: () {
                    _showFilterBottomSheet();
                  },
                ),
                // Info icon to show that trip creation is disabled
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Création de voyages désactivée',
                  onPressed: () {
                    _tripsCubit.showTripCreationDenied();
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Search and Filter Section
                _buildSearchAndFilterSection(state),

                // Statistics Row
                _buildStatisticsRow(state),

                // Trips List
                Expanded(child: _buildTripsList(state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripsList(TripsState state) {
    if (state is TripsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is TripsError) {
      return Center(
        child: EmptyStateWidget(
          title: 'Erreur',
          message: state.message,
          icon: Icons.error_outline_rounded,
          onActionPressed: () => _tripsCubit.refreshTrips(),
          actionLabel: 'Réessayer',
        ),
      );
    } else if (state is TripsLoaded) {
      if (state.filteredTrips.isEmpty) {
        return EmptyStateWidget(
          title: 'Aucun voyage trouvé',
          message:
              'Essayez de modifier vos filtres pour voir les voyages disponibles',
          icon: Icons.route_rounded,
          onActionPressed: () => _tripsCubit.refreshTrips(),
          actionLabel: 'Actualiser',
        );
      } else {
        return RefreshIndicator(
          onRefresh: () => _tripsCubit.refreshTrips(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            itemCount: state.filteredTrips.length,
            itemBuilder: (context, index) {
              final trip = state.filteredTrips[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: TripCard(
                  trip: _tripToMap(trip),
                  onTap: () => _navigateToTripDetails(trip),
                ),
              );
            },
          ),
        );
      }
    }

    // Default empty widget for initial state
    return const SizedBox.shrink();
  }

  // Helper method to convert Trip object to Map for legacy TripCard widget
  Map<String, dynamic> _tripToMap(Trip trip) {
    return {
      'id': trip.id?.toString() ?? '',
      'name': trip.name,
      'state': trip.state.name,
      'tripType': trip.tripType.name,
      'departureCity': trip.departureCity,
      'destinationCity': trip.destinationCity,
      'departureCountry': trip.departureCountryId,
      'destinationCountry': trip.destinationCountryId,
      'departureCountryName': trip.departureCountryName,
      'destinationCountryName': trip.destinationCountryName,
      'departureDate': trip.departureDate,
      'arrivalDate': trip.arrivalDate,
      'actualArrivalDate': trip.actualArrivalDate,
      'returnDate': trip.returnDate,
      'vehicleId': trip.vehicleId,
      'driverId': trip.driverId,
      'coDriverId': trip.coDriverId,
      'serviceType': trip.serviceType.name,
      'cargoDescription': trip.cargoDescription,
      'cargoWeight': trip.cargoWeight ?? 0.0,
      'passengerCount': trip.passengerCount ?? 0,
      'totalRevenue': trip.totalRevenue,
      'totalExpenses': trip.totalExpenses,
      'profit': trip.profit,
      'profitMargin': trip.profitMargin,
      'notes': trip.notes,
      'distanceKm': trip.distanceKm ?? 0.0,
      'fuelConsumption': trip.fuelConsumption ?? 0.0,
      'durationDays': trip.durationDays,
      'trailerId': trip.trailerId,
      'companyId': trip.companyId,
      // Additional fields for TripCard widget
      'status': trip.state.name.toLowerCase(),
      'driverName': trip.driverId,
      'vehiclePlate': trip.vehicleId,
      'distance': trip.distanceKm ?? 0.0,
      'revenue': trip.totalRevenue,
      'expenses': trip.totalExpenses,
      'trip_type': trip.tripType.name,
      'service_type': trip.serviceType.name,
      'departureDateStr': trip.departureDate.toString(),
      'arrivalDateStr': trip.arrivalDate?.toString(),
      'departureCountryName': trip.departureCountryName,
      'destinationCountryName': trip.destinationCountryName,
      'currency': trip.currencyId,
    };
  }

  Widget _buildSearchAndFilterSection(TripsState state) {
    String currentQuery = '';
    String currentStatus = 'Tous';

    if (state is TripsLoaded) {
      currentQuery = state.searchQuery;
      currentStatus = state.selectedStatus;

      // Update search controller text if needed
      if (_searchController.text != currentQuery) {
        _searchController.text = currentQuery;
      }
    }

    return Container(
      color: AppColors.primary,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey300.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _tripsCubit.applyFilters(searchQuery: value);
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un voyage...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: currentQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _tripsCubit.applyFilters(searchQuery: '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    [
                      {'value': 'Tous', 'label': 'Tous'},
                      {'value': 'in_progress', 'label': 'En cours'},
                      {'value': 'done', 'label': 'Terminé'},
                      {'value': 'draft', 'label': 'Brouillon'},
                      {'value': 'delivered', 'label': 'Livré'},
                      {'value': 'cancelled', 'label': 'Annulé'},
                    ].map((statusMap) {
                      final value = statusMap['value'] as String;
                      final label = statusMap['label'] as String;
                      final isSelected = currentStatus == value;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: FilterChipWidget(
                          label: label,
                          isSelected: isSelected,
                          onSelected: (selected) {
                            _tripsCubit.applyFilters(status: value);
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow(TripsState state) {
    // Default values
    String totalTrips = '0';
    String ongoingTrips = '0';
    String completedTrips = '0';

    if (state is TripsLoaded) {
      totalTrips = state.filteredTrips.length.toString();
      ongoingTrips = state.filteredTrips
          .where((trip) => trip.state.name.toLowerCase() == 'in_progress')
          .length
          .toString();
      completedTrips = state.filteredTrips
          .where((trip) => trip.state.name.toLowerCase() == 'done')
          .length
          .toString();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: TripStatCard(
              title: 'Total voyages',
              value: totalTrips,
              icon: Icons.route_rounded,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TripStatCard(
              title: 'En cours',
              value: ongoingTrips,
              icon: Icons.sync_rounded,
              color: AppColors.warning,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TripStatCard(
              title: 'Terminés',
              value: completedTrips,
              icon: Icons.check_circle_rounded,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    final context = _tripsCubit.context;
    if (context != null) {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtres avancés',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              const Text('Fonctionnalité en cours de développement'),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _navigateToTripDetails(Trip trip) {
    final context = _tripsCubit.context;
    if (context != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TripDetailsScreen(trip: trip)),
      );
    }
  }

  // These utility methods have been moved to TripUtils class
  // and are no longer used in this file.
}
