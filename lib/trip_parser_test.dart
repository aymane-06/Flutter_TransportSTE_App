import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  // Test case
  final json = {
    'departure_country_id': [136, "Morocco"],
    'destination_country_id': [69, "France"],
  };

  // Helper function to extract Name from Many2one field
  String extractMany2oneName(dynamic field) {
    if (field == null || field == false) return '';
    if (field is List && field.length > 1) {
      return field[1].toString();
    }
    return '';
  }
  
  // Extract the names
  final departureCountryName = extractMany2oneName(json['departure_country_id']);
  final destinationCountryName = extractMany2oneName(json['destination_country_id']);
  
  // Print the results
  debugPrint('Departure country name: $departureCountryName');
  debugPrint('Destination country name: $destinationCountryName');
}
