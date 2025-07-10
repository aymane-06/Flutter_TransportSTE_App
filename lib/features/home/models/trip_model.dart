class Trip {
  final String? id;
  final String name;
  final String departureCountryId;
  final String destinationCountryId;
  final String departureCountryName;
  final String destinationCountryName;
  final String departureCity;
  final String destinationCity;
  final TripType tripType;
  final DateTime departureDate;
  final DateTime? arrivalDate;
  final DateTime? actualArrivalDate;
  final DateTime? returnDate;
  final String vehicleId;
  final String driverId;
  final String? coDriverId;
  final TripState state;
  final ServiceType serviceType;
  final String? cargoDescription;
  final double? cargoWeight;
  final int? passengerCount;
  final List<String> revenueIds;
  final List<String> expenseIds;
  final double totalRevenue;
  final double totalExpenses;
  final double profit;
  final double profitMargin;
  final String? currencyId;
  final String? notes;
  final double? distanceKm;
  final double? fuelConsumption;
  final double durationDays;
  final String? trailerId;
  final String companyId;

  Trip({
    this.id,
    required this.name,
    required this.departureCountryId,
    required this.destinationCountryId,
    this.departureCountryName = '',
    this.destinationCountryName = '',
    required this.departureCity,
    required this.destinationCity,
    this.tripType = TripType.oneWay,
    required this.departureDate,
    this.arrivalDate,
    this.actualArrivalDate,
    this.returnDate,
    required this.vehicleId,
    required this.driverId,
    this.coDriverId,
    this.state = TripState.draft,
    required this.serviceType,
    this.cargoDescription,
    this.cargoWeight,
    this.passengerCount,
    this.revenueIds = const [],
    this.expenseIds = const [],
    this.totalRevenue = 0.0,
    this.totalExpenses = 0.0,
    this.profit = 0.0,
    this.profitMargin = 0.0,
    this.currencyId,
    this.notes,
    this.distanceKm,
    this.fuelConsumption,
    this.durationDays = 0.0,
    this.trailerId,
    required this.companyId,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    print('Parsing Trip from JSON: $json');

    // Helper function to extract ID from Many2one field
    String? extractMany2oneId(dynamic field) {
      if (field == null || field == false) return null;
      if (field is List && field.isNotEmpty) {
        return field[0].toString();
      }
      return field.toString();
    }
    
    // Helper function to extract Name from Many2one field
    String extractMany2oneName(dynamic field) {
      if (field == null || field == false) return '';
      if (field is List && field.length > 1) {
        return field[1].toString();
      }
      return '';
    }

    // Helper function to safely parse dates that could be 'false'
    DateTime? parseOdooDate(dynamic dateValue) {
      if (dateValue == null || dateValue == false) return null;
      try {
        return DateTime.parse(dateValue.toString());
      } catch (e) {
        print('Error parsing date: $dateValue - $e');
        return null;
      }
    }

    try {
      return Trip(
        id: json['id']?.toString(),
        name: json['name'] ?? 'Unknown Trip',
        departureCountryId:
            extractMany2oneId(json['departure_country_id']) ?? '',
        destinationCountryId:
            extractMany2oneId(json['destination_country_id']) ?? '',
        departureCountryName:
            extractMany2oneName(json['departure_country_id']),
        destinationCountryName:
            extractMany2oneName(json['destination_country_id']),
        departureCity: json['departure_city'] ?? '',
        destinationCity: json['destination_city'] ?? '',
        tripType: TripType.values.firstWhere(
          (e) => e.name == json['trip_type'],
          orElse: () => TripType.oneWay,
        ),
        departureDate: parseOdooDate(json['departure_date']) ?? DateTime.now(),
        arrivalDate: parseOdooDate(json['arrival_date']),
        actualArrivalDate: parseOdooDate(json['actual_arrival_date']),
        returnDate: parseOdooDate(json['return_date']),
        vehicleId: extractMany2oneId(json['vehicle_id']) ?? '',
        driverId: extractMany2oneId(json['driver_id']) ?? '',
        coDriverId: extractMany2oneId(json['co_driver_id']),
        state: TripState.values.firstWhere(
          (e) => e.name == json['state'],
          orElse: () => TripState.draft,
        ),
        serviceType: ServiceType.values.firstWhere(
          (e) => e.name == json['service_type'],
          orElse: () => ServiceType.cargo,
        ),
        cargoDescription: json['cargo_description'] == false
            ? null
            : json['cargo_description']?.toString(),
        cargoWeight: json['cargo_weight'] == false
            ? null
            : (json['cargo_weight'] is num
                  ? json['cargo_weight'].toDouble()
                  : double.tryParse(json['cargo_weight']?.toString() ?? '') ??
                        0.0),
        passengerCount: json['passenger_count'] == false
            ? null
            : (json['passenger_count'] is num
                  ? json['passenger_count'].toInt()
                  : int.tryParse(json['passenger_count']?.toString() ?? '') ??
                        0),
        revenueIds: json['revenue_ids'] == false
            ? []
            : (json['revenue_ids'] is List
                  ? (json['revenue_ids'] as List)
                        .map((e) => e.toString())
                        .toList()
                  : []),
        expenseIds: json['expense_ids'] == false
            ? []
            : (json['expense_ids'] is List
                  ? (json['expense_ids'] as List)
                        .map((e) => e.toString())
                        .toList()
                  : []),
        totalRevenue: json['total_revenue'] == false
            ? 0.0
            : (json['total_revenue'] is num
                  ? json['total_revenue'].toDouble()
                  : double.tryParse(json['total_revenue']?.toString() ?? '') ??
                        0.0),
        totalExpenses: json['total_expenses'] == false
            ? 0.0
            : (json['total_expenses'] is num
                  ? json['total_expenses'].toDouble()
                  : double.tryParse(json['total_expenses']?.toString() ?? '') ??
                        0.0),
        profit: json['profit'] == false
            ? 0.0
            : (json['profit'] is num
                  ? json['profit'].toDouble()
                  : double.tryParse(json['profit']?.toString() ?? '') ?? 0.0),
        profitMargin: json['profit_margin'] == false
            ? 0.0
            : (json['profit_margin'] is num
                  ? json['profit_margin'].toDouble()
                  : double.tryParse(json['profit_margin']?.toString() ?? '') ??
                        0.0),
        currencyId: extractMany2oneId(json['currency_id']),
        notes: json['notes'] == false ? null : json['notes']?.toString(),
        distanceKm: json['distance_km'] == false
            ? null
            : (json['distance_km'] is num
                  ? json['distance_km'].toDouble()
                  : double.tryParse(json['distance_km']?.toString() ?? '') ??
                        0.0),
        fuelConsumption: json['fuel_consumption'] == false
            ? null
            : (json['fuel_consumption'] is num
                  ? json['fuel_consumption'].toDouble()
                  : double.tryParse(
                          json['fuel_consumption']?.toString() ?? '',
                        ) ??
                        0.0),
        durationDays: json['duration_days'] == false
            ? 0.0
            : (json['duration_days'] is num
                  ? json['duration_days'].toDouble()
                  : double.tryParse(json['duration_days']?.toString() ?? '') ??
                        0.0),
        trailerId: extractMany2oneId(json['trailer_id']),
        companyId: extractMany2oneId(json['company_id']) ?? '',
      );
    } catch (e, stackTrace) {
      print('Error parsing Trip from JSON: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');

      // Return a default trip if parsing fails
      return Trip(
        id: json['id']?.toString() ?? '0',
        name: json['name']?.toString() ?? 'Unknown Trip',
        departureCountryId: '',
        destinationCountryId: '',
        departureCountryName: '',
        destinationCountryName: '',
        departureCity: json['departure_city']?.toString() ?? 'Unknown',
        destinationCity: json['destination_city']?.toString() ?? 'Unknown',
        departureDate: DateTime.now(),
        vehicleId: '',
        driverId: '',
        serviceType: ServiceType.cargo,
        companyId: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'departure_country_id': departureCountryId,
      'destination_country_id': destinationCountryId,
      'departure_country_name': departureCountryName,
      'destination_country_name': destinationCountryName,
      'departure_city': departureCity,
      'destination_city': destinationCity,
      'trip_type': tripType.name,
      'departure_date': departureDate.toIso8601String(),
      'arrival_date': arrivalDate?.toIso8601String(),
      'actual_arrival_date': actualArrivalDate?.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'co_driver_id': coDriverId,
      'state': state.name,
      'service_type': serviceType.name,
      'cargo_description': cargoDescription,
      'cargo_weight': cargoWeight,
      'passenger_count': passengerCount,
      'revenue_ids': revenueIds,
      'expense_ids': expenseIds,
      'total_revenue': totalRevenue,
      'total_expenses': totalExpenses,
      'profit': profit,
      'profit_margin': profitMargin,
      'currency_id': currencyId,
      'notes': notes,
      'distance_km': distanceKm,
      'fuel_consumption': fuelConsumption,
      'duration_days': durationDays,
      'trailer_id': trailerId,
      'company_id': companyId,
    };
  }

  Trip copyWith({
    String? id,
    String? name,
    String? departureCountryId,
    String? destinationCountryId,
    String? departureCountryName,
    String? destinationCountryName,
    String? departureCity,
    String? destinationCity,
    TripType? tripType,
    DateTime? departureDate,
    DateTime? arrivalDate,
    DateTime? actualArrivalDate,
    DateTime? returnDate,
    String? vehicleId,
    String? driverId,
    String? coDriverId,
    TripState? state,
    ServiceType? serviceType,
    String? cargoDescription,
    double? cargoWeight,
    int? passengerCount,
    List<String>? revenueIds,
    List<String>? expenseIds,
    double? totalRevenue,
    double? totalExpenses,
    double? profit,
    double? profitMargin,
    String? currencyId,
    String? notes,
    double? distanceKm,
    double? fuelConsumption,
    double? durationDays,
    String? trailerId,
    String? companyId,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      departureCountryId: departureCountryId ?? this.departureCountryId,
      destinationCountryId: destinationCountryId ?? this.destinationCountryId,
      departureCountryName: departureCountryName ?? this.departureCountryName,
      destinationCountryName: destinationCountryName ?? this.destinationCountryName,
      departureCity: departureCity ?? this.departureCity,
      destinationCity: destinationCity ?? this.destinationCity,
      tripType: tripType ?? this.tripType,
      departureDate: departureDate ?? this.departureDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      actualArrivalDate: actualArrivalDate ?? this.actualArrivalDate,
      returnDate: returnDate ?? this.returnDate,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      coDriverId: coDriverId ?? this.coDriverId,
      state: state ?? this.state,
      serviceType: serviceType ?? this.serviceType,
      cargoDescription: cargoDescription ?? this.cargoDescription,
      cargoWeight: cargoWeight ?? this.cargoWeight,
      passengerCount: passengerCount ?? this.passengerCount,
      revenueIds: revenueIds ?? this.revenueIds,
      expenseIds: expenseIds ?? this.expenseIds,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      profit: profit ?? this.profit,
      profitMargin: profitMargin ?? this.profitMargin,
      currencyId: currencyId ?? this.currencyId,
      notes: notes ?? this.notes,
      distanceKm: distanceKm ?? this.distanceKm,
      fuelConsumption: fuelConsumption ?? this.fuelConsumption,
      durationDays: durationDays ?? this.durationDays,
      trailerId: trailerId ?? this.trailerId,
      companyId: companyId ?? this.companyId,
    );
  }
}

enum TripType {
  oneWay('one_way'),
  roundTrip('round_trip');

  const TripType(this.value);
  final String value;
  String get name => value;
}

enum TripState {
  draft('draft'),
  confirmed('confirmed'),
  inProgress('in_progress'),
  delivered('delivered'),
  returned('returned'),
  done('done'),
  cancelled('cancelled');

  const TripState(this.value);
  final String value;
  String get name => value;
}

enum ServiceType {
  cargo('cargo'),
  passenger('passenger'),
  mixed('mixed');

  const ServiceType(this.value);
  final String value;
  String get name => value;
}
