import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/trip_model.dart';
import '../../utils/trip_utils.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Détails du Voyage',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Mode lecture uniquement',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Mode consultation uniquement. Vous ne pouvez pas modifier ce voyage.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: TripDetailsView(trip: trip),
    );
  }
}

class TripDetailsView extends StatelessWidget {
  final Trip trip;

  const TripDetailsView({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header with trip status banner
          _buildStatusHeader(),

          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripOverview(context),
                  SizedBox(height: 24.h),
                  _buildRouteSection(),
                  SizedBox(height: 24.h),
                  _buildFinancialSection(),
                  SizedBox(height: 24.h),
                  _buildDatesSection(),
                  SizedBox(height: 24.h),
                  _buildTransportSection(),
                  SizedBox(height: 24.h),
                  _buildCargoOrPassengerSection(),
                  SizedBox(height: 24.h),
                  if (trip.notes != null && trip.notes!.isNotEmpty) ...[
                    _buildNotesSection(),
                    SizedBox(height: 24.h),
                  ],
                  _buildReadOnlyBanner(),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    final Color statusColor = TripUtils.getStatusColor(trip.state.name);
    final String statusText = TripUtils.getStatusName(trip.state.name);

    return Container(
      width: double.infinity,
      color: statusColor.withOpacity(0.1),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              statusText.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  'ID: ${trip.id ?? "N/A"}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripOverview(BuildContext context) {
    final tripType = TripUtils.getTripTypeName(trip.tripType.name);
    final serviceType = TripUtils.getServiceTypeName(trip.serviceType.name);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu du Voyage',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    icon: Icons.compare_arrows,
                    title: 'Type',
                    value: tripType,
                  ),
                ),
                Expanded(
                  child: _infoItem(
                    icon: trip.serviceType == ServiceType.passenger
                        ? Icons.person
                        : Icons.local_shipping,
                    title: 'Service',
                    value: serviceType,
                  ),
                ),
                Expanded(
                  child: _infoItem(
                    icon: Icons.calendar_today,
                    title: 'Durée',
                    value: '${trip.durationDays} jours',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSection() {
    // Use the country name directly from the Trip model
    String departureCountry = trip.departureCountryName.isNotEmpty
        ? trip.departureCountryName
        : TripUtils.getDisplayNameFromMany2One(trip.departureCountryId);

    String destinationCountry = trip.destinationCountryName.isNotEmpty
        ? trip.destinationCountryName
        : TripUtils.getDisplayNameFromMany2One(trip.destinationCountryId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itinéraire',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16.w,
                      ),
                    ),
                    Container(
                      width: 2.w,
                      height: 60.h,
                      color: Colors.grey.shade300,
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.flag, color: Colors.white, size: 16.w),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Départ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            trip.departureCity,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            departureCountry,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destination',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            trip.destinationCity,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            destinationCountry,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (trip.distanceKm != null && trip.distanceKm! > 0) ...[
              SizedBox(height: 16.h),
              Divider(),
              SizedBox(height: 8.h),
              _detailRow('Distance', '${trip.distanceKm!} km'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSection() {
    String currencyCode = TripUtils.getDisplayNameFromMany2One(
      trip.currencyId,
      defaultValue: 'USD',
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finances',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _financialItem(
                    title: 'Revenus',
                    value:
                        '${trip.totalRevenue.toStringAsFixed(2)} $currencyCode',
                    color: Colors.green,
                    icon: Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _financialItem(
                    title: 'Dépenses',
                    value:
                        '${trip.totalExpenses.toStringAsFixed(2)} $currencyCode',
                    color: Colors.red,
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _financialItem(
                    title: 'Profit',
                    value: '${trip.profit.toStringAsFixed(2)} $currencyCode',
                    color: Colors.blue,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _financialItem(
                    title: 'Marge',
                    value: '${trip.profitMargin.toStringAsFixed(2)} %',
                    color: Colors.orange,
                    icon: Icons.pie_chart,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dates',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            _dateRow(
              title: 'Date de départ',
              date: trip.departureDate,
              icon: Icons.flight_takeoff,
              color: Colors.blue,
            ),
            if (trip.arrivalDate != null)
              _dateRow(
                title: 'Date d\'arrivée prévue',
                date: trip.arrivalDate!,
                icon: Icons.flight_land,
                color: Colors.green,
              ),
            if (trip.actualArrivalDate != null)
              _dateRow(
                title: 'Date d\'arrivée effective',
                date: trip.actualArrivalDate!,
                icon: Icons.check_circle,
                color: Colors.teal,
              ),
            if (trip.returnDate != null)
              _dateRow(
                title: 'Date de retour',
                date: trip.returnDate!,
                icon: Icons.flight_takeoff,
                color: Colors.purple,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportSection() {
    String vehicleInfo = TripUtils.getDisplayNameFromMany2One(trip.vehicleId);
    String driverInfo = TripUtils.getDisplayNameFromMany2One(trip.driverId);
    String? trailerInfo = trip.trailerId != null
        ? TripUtils.getDisplayNameFromMany2One(trip.trailerId)
        : null;
    String? coDriverInfo = trip.coDriverId != null
        ? TripUtils.getDisplayNameFromMany2One(trip.coDriverId)
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transport',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            _detailRow('Véhicule', vehicleInfo),
            _detailRow('Chauffeur', driverInfo),
            if (coDriverInfo != null) _detailRow('Co-Chauffeur', coDriverInfo),
            if (trailerInfo != null) _detailRow('Remorque', trailerInfo),
            if (trip.fuelConsumption != null)
              _detailRow(
                'Consommation carburant',
                '${trip.fuelConsumption!} L/100km',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCargoOrPassengerSection() {
    final isPassengerTrip = trip.serviceType == ServiceType.passenger;
    final isMixedTrip = trip.serviceType == ServiceType.mixed;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPassengerTrip
                  ? 'Informations Passagers'
                  : isMixedTrip
                  ? 'Informations Cargo et Passagers'
                  : 'Informations Cargo',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            if (!isPassengerTrip) ...[
              if (trip.cargoDescription != null &&
                  trip.cargoDescription!.isNotEmpty)
                _detailRow('Description', trip.cargoDescription!),
              if (trip.cargoWeight != null)
                _detailRow('Poids', '${trip.cargoWeight} kg'),
            ],
            if (isPassengerTrip || isMixedTrip) ...[
              if (trip.passengerCount != null)
                _detailRow(
                  'Nombre de passagers',
                  trip.passengerCount?.toString() ?? 'N/A',
                ),
            ],
            if ((!isPassengerTrip &&
                    trip.cargoDescription == null &&
                    trip.cargoWeight == null) ||
                ((isPassengerTrip || isMixedTrip) &&
                    trip.passengerCount == null))
              Text(
                'Aucune information disponible',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                trip.notes ?? '',
                style: TextStyle(fontSize: 14.sp, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyBanner() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.red, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Mode consultation uniquement. Vous ne pouvez pas modifier ce voyage.',
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24.w),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _financialItem({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16.w),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _dateRow({
    required String title,
    required DateTime date,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                TripUtils.formatDateTime(date),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
