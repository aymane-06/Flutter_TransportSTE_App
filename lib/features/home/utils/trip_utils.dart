import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

/// A utility class for trip-related formatting and helper methods
class TripUtils {
  /// Formats a DateTime object to a readable string format
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }

  /// Returns the appropriate color for a given trip status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
      case 'brouillon':
        return Colors.grey;
      case 'confirmed':
      case 'confirmé':
        return Colors.blue;
      case 'in_progress':
      case 'en cours':
        return AppColors.warning;
      case 'delivered':
      case 'livré':
        return Colors.lightGreen;
      case 'returned':
      case 'retourné':
        return Colors.teal;
      case 'done':
      case 'terminé':
        return Colors.green;
      case 'cancelled':
      case 'annulé':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  /// Returns the French name for a given trip status
  static String getStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Brouillon';
      case 'confirmed':
        return 'Confirmé';
      case 'in_progress':
        return 'En cours';
      case 'delivered':
        return 'Livré';
      case 'returned':
        return 'Retourné';
      case 'done':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  /// Returns the French name for a given trip type
  static String getTripTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'one_way':
        return 'Aller simple';
      case 'round_trip':
        return 'Aller-retour';
      default:
        return type;
    }
  }

  /// Returns the French name for a given service type
  static String getServiceTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'cargo':
        return 'Transport de marchandises';
      case 'passenger':
        return 'Transport de passagers';
      case 'mixed':
        return 'Transport mixte';
      default:
        return type;
    }
  }

  /// Extracts a display name from an Odoo many2one field
  /// Many2one fields in Odoo are often represented as "id,name" strings or [id, name] lists
  static String getDisplayNameFromMany2One(
    dynamic fieldValue, {
    String defaultValue = 'N/A',
  }) {
    if (fieldValue == null) {
      return defaultValue;
    }

    // Handle List format: [id, name]
    if (fieldValue is List && fieldValue.length > 1) {
      return fieldValue[1].toString();
    }

    // Handle String format: "id,name"
    if (fieldValue is String) {
      if (fieldValue.isEmpty) {
        return defaultValue;
      }

      if (fieldValue.contains(',')) {
        final parts = fieldValue.split(',');
        if (parts.length > 1) {
          return parts[1].trim();
        }
      }

      return fieldValue;
    }

    return fieldValue?.toString() ?? defaultValue;
  }
}
