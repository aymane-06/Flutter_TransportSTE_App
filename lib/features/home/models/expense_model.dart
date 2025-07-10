class TripExpense {
  final String? id;
  final String tripId;
  final String name;
  final ExpenseType expenseType;
  final double amount;
  final String? currencyId;
  final DateTime date;
  final String? location;
  final String? supplier;
  final String? receiptNumber;
  final String? notes;
  final String? vehicleId;
  final String? driverId;
  final String companyId;

  TripExpense({
    this.id,
    required this.tripId,
    required this.name,
    required this.expenseType,
    required this.amount,
    this.currencyId,
    required this.date,
    this.location,
    this.supplier,
    this.receiptNumber,
    this.notes,
    this.vehicleId,
    this.driverId,
    required this.companyId,
  });

  factory TripExpense.fromJson(Map<String, dynamic> json) {
    print('Parsing TripExpense from JSON: $json');

    // Helper function to extract ID from Many2one field
    String? extractMany2oneId(dynamic field) {
      if (field == null || field == false) return null;
      if (field is List && field.isNotEmpty) {
        return field[0].toString();
      }
      return field.toString();
    }

    try {
      return TripExpense(
        id: json['id']?.toString(),
        tripId: extractMany2oneId(json['trip_id']) ?? '',
        name: json['name'] ?? 'Unknown Expense',
        expenseType: ExpenseType.values.firstWhere(
          (e) => e.name == json['expense_type'],
          orElse: () => ExpenseType.other,
        ),
        amount: json['amount']?.toDouble() ?? 0.0,
        currencyId: extractMany2oneId(json['currency_id']),
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
        location: json['location'],
        supplier: json['supplier'],
        receiptNumber: json['receipt_number'],
        notes: json['notes'],
        vehicleId: extractMany2oneId(json['vehicle_id']),
        driverId: extractMany2oneId(json['driver_id']),
        companyId: extractMany2oneId(json['company_id']) ?? '',
      );
    } catch (e) {
      print('Error parsing TripExpense from JSON: $e');
      print('JSON data: $json');

      // Return a default expense if parsing fails
      return TripExpense(
        id: json['id']?.toString(),
        tripId: '',
        name: json['name'] ?? 'Unknown Expense',
        expenseType: ExpenseType.other,
        amount: json['amount']?.toDouble() ?? 0.0,
        date: DateTime.now(),
        companyId: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'name': name,
      'expense_type': expenseType.name,
      'amount': amount,
      'currency_id': currencyId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'location': location,
      'supplier': supplier,
      'receipt_number': receiptNumber,
      'notes': notes,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'company_id': companyId,
    };
  }

  TripExpense copyWith({
    String? id,
    String? tripId,
    String? name,
    ExpenseType? expenseType,
    double? amount,
    String? currencyId,
    DateTime? date,
    String? location,
    String? supplier,
    String? receiptNumber,
    String? notes,
    String? vehicleId,
    String? driverId,
    String? companyId,
  }) {
    return TripExpense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      expenseType: expenseType ?? this.expenseType,
      amount: amount ?? this.amount,
      currencyId: currencyId ?? this.currencyId,
      date: date ?? this.date,
      location: location ?? this.location,
      supplier: supplier ?? this.supplier,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      notes: notes ?? this.notes,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      companyId: companyId ?? this.companyId,
    );
  }

  // Helper method to get expense type display name
  String get expenseTypeDisplayName {
    switch (expenseType) {
      case ExpenseType.fuel:
        return 'Fuel';
      case ExpenseType.toll:
        return 'Toll/Péages';
      case ExpenseType.customs:
        return 'Customs/Douane';
      case ExpenseType.accommodation:
        return 'Accommodation/Hébergement';
      case ExpenseType.meals:
        return 'Meals/Repas';
      case ExpenseType.maintenance:
        return 'Maintenance';
      case ExpenseType.insurance:
        return 'Insurance';
      case ExpenseType.parking:
        return 'Parking';
      case ExpenseType.driverAllowance:
        return 'Driver Allowance';
      case ExpenseType.other:
        return 'Other';
    }
  }
}

enum ExpenseType {
  fuel('fuel'),
  toll('toll'),
  customs('customs'),
  accommodation('accommodation'),
  meals('meals'),
  maintenance('maintenance'),
  insurance('insurance'),
  parking('parking'),
  driverAllowance('driver_allowance'),
  other('other');

  const ExpenseType(this.value);
  final String value;
  String get name => value;
}
