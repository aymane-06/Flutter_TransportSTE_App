import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../utils/trip_utils.dart';

class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onTap;

  const TripCard({super.key, required this.trip, required this.onTap});

  String _formatDate(String? dateString) {
    if (dateString == null || dateString == 'false') return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _extractValue(dynamic field) {
    if (field == null || field == false) return 'N/A';
    if (field is List && field.length > 1) return field[1].toString();
    return field.toString();
  }

  String _formatDuration(dynamic days) {
    if (days == null || days == 0) return 'N/A';
    final durationDays = double.tryParse(days.toString()) ?? 0;
    if (durationDays == 1) return '1 jour';
    return '$durationDays jours';
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'en cours':
        return '0xFFFFA000'; // Warning/Amber
      case 'done':
      case 'terminé':
        return '0xFF4CAF50'; // Success/Green
      case 'draft':
      case 'brouillon':
        return '0xFF2196F3'; // Info/Blue
      case 'delivered':
      case 'livré':
        return '0xFF00BCD4'; // Cyan
      case 'returned':
      case 'retourné':
        return '0xFF9C27B0'; // Purple
      case 'cancelled':
      case 'en retard':
      case 'annulé':
        return '0xFFE53935'; // Error/Red
      case 'confirmed':
      case 'confirmé':
        return '0xFF00796B'; // Teal
      default:
        return '0xFF9E9E9E'; // Grey
    }
  }

  String _getStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'En cours';
      case 'done':
        return 'Terminé';
      case 'draft':
        return 'Brouillon';
      case 'delivered':
        return 'Livré';
      case 'returned':
        return 'Retourné';
      case 'cancelled':
        return 'Annulé';
      case 'confirmed':
        return 'Confirmé';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String statusText = _getStatusName(trip['status'] ?? '');
    final String statusColor = _getStatusColor(trip['status'] ?? '');

    // Extract vehicle info if available
    String vehicleInfo = 'N/A';
    if (trip['vehicleId'] != null && trip['vehicleId'] != false) {
      if (trip['vehicleId'].toString().contains(',')) {
        final parts = trip['vehicleId'].toString().split(',');
        if (parts.length > 1) {
          vehicleInfo = parts[1].trim();
        } else {
          vehicleInfo = parts[0].trim();
        }
      } else {
        vehicleInfo = trip['vehicleId'].toString();
      }
    } else if (trip['vehiclePlate'] != null && trip['vehiclePlate'] != false) {
      vehicleInfo = trip['vehiclePlate'].toString();
    }

    // Extract driver info
    String driverInfo = 'N/A';
    if (trip['driverId'] != null && trip['driverId'] != false) {
      if (trip['driverId'].toString().contains(',')) {
        final parts = trip['driverId'].toString().split(',');
        if (parts.length > 1) {
          driverInfo = parts[1].trim();
        } else {
          driverInfo = parts[0].trim();
        }
      } else {
        driverInfo = trip['driverId'].toString();
      }
    } else if (trip['driverName'] != null && trip['driverName'] != false) {
      driverInfo = trip['driverName'].toString();
    }

    // Format departure date (currently not used directly in the UI but available for future use)
    // We'll use this later if we need to display the specific date

    // Format duration
    String duration = 'N/A';
    if (trip['durationDays'] != null && trip['durationDays'] != 0) {
      final durationDays =
          double.tryParse(trip['durationDays'].toString()) ?? 0;
      if (durationDays == 1) {
        duration = '1 jour';
      } else {
        duration = '$durationDays jours';
      }
    }

    // Country information has been removed as we're displaying only city names now

    // Get trip type
    String tripType = trip['trip_type'] == 'round_trip'
        ? 'Aller-retour'
        : 'Aller simple';

    // Format currency
    String currency = 'MAD';
    if (trip['currency'] != null && trip['currency'] != false) {
      currency = TripUtils.getDisplayNameFromMany2One(
        trip['currency'] is String ? trip['currency'] : null,
        defaultValue: 'MAD',
      );
    } else if (trip['currencyId'] != null && trip['currencyId'] != false) {
      currency = TripUtils.getDisplayNameFromMany2One(
        trip['currencyId'] is String ? trip['currencyId'] : null,
        defaultValue: 'MAD',
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        trip['name'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(int.parse(statusColor)).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(int.parse(statusColor)),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              Divider(height: 16.h),

              // Route information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Itinéraire',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14.sp,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              trip['departureCity'] ?? 'N/A',
                                              style: TextStyle(fontSize: 13.sp),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              trip['departureCountryName'] != null && 
                                              trip['departureCountryName'].toString().isNotEmpty ? 
                                              trip['departureCountryName'].toString() : 'N/A',
                                              style: TextStyle(
                                                fontSize: 11.sp, 
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 18.w),
                                      Container(
                                        height: 20.h,
                                        width: 1.w,
                                        color: AppColors.grey300,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14.sp,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              trip['destinationCity'] ?? 'N/A',
                                              style: TextStyle(fontSize: 13.sp),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              trip['destinationCountryName'] != null && 
                                              trip['destinationCountryName'].toString().isNotEmpty ? 
                                              trip['destinationCountryName'].toString() : 'N/A',
                                              style: TextStyle(
                                                fontSize: 11.sp, 
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Durée',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey600,
                          ),
                        ),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Trip details (type and date)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              trip['trip_type'] == 'round_trip'
                                  ? Icons.compare_arrows
                                  : Icons.arrow_forward,
                              size: 14.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(tripType, style: TextStyle(fontSize: 12.sp)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              trip['service_type'] == 'cargo'
                                  ? Icons.local_shipping_outlined
                                  : Icons.people_alt_outlined,
                              size: 14.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              trip['service_type'] == 'cargo'
                                  ? 'Marchandise'
                                  : 'Passagers',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Vehicle and driver
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Véhicule',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              size: 14.sp,
                              color: AppColors.grey600,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                vehicleInfo,
                                style: TextStyle(fontSize: 12.sp),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chauffeur',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14.sp,
                              color: AppColors.grey600,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                driverInfo,
                                style: TextStyle(fontSize: 12.sp),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Financial information
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
                        horizontal: 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Revenus',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(trip['totalRevenue'] ?? trip['revenue'] ?? 0).toStringAsFixed(2)} $currency',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
                        horizontal: 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Dépenses',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(trip['totalExpenses'] ?? trip['expenses'] ?? 0).toStringAsFixed(2)} $currency',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
                        horizontal: 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Profit',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(trip['profit'] ?? 0).toStringAsFixed(2)} $currency',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
