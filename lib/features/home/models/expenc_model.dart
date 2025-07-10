class ExpenseModel {
  final String? id;
  final String tripId;
  final String name;
  final ExpenseType expenseType;
  final double amount;
  final String currencyId;
  final DateTime date;
  final String? location;
  final String? supplier;
  final String? receiptNumber;
  final String? notes;
  final String? vehicleId;
  final String? driverId;
  final String companyId;

  const ExpenseModel({
    this.id,
    required this.tripId,
    required this.name,
    required this.expenseType,
    required this.amount,
    required this.currencyId,
    required this.date,
    this.location,
    this.supplier,
    this.receiptNumber,
    this.notes,
    this.vehicleId,
    this.driverId,
    required this.companyId,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString(),
      tripId: json['trip_id'].toString(),
      name: json['name'],
      expenseType: ExpenseType.fromString(json['expense_type']),
      amount: (json['amount'] as num).toDouble(),
      currencyId: json['currency_id'].toString(),
      date: DateTime.parse(json['date']),
      location: json['location'],
      supplier: json['supplier'],
      receiptNumber: json['receipt_number'],
      notes: json['notes'],
      vehicleId: json['vehicle_id']?.toString(),
      driverId: json['driver_id']?.toString(),
      companyId: json['company_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      'name': name,
      'expense_type': expenseType.value,
      'amount': amount,
      'currency_id': currencyId,
      'date': date.toIso8601String(),
      if (location != null) 'location': location,
      if (supplier != null) 'supplier': supplier,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (notes != null) 'notes': notes,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (driverId != null) 'driver_id': driverId,
      'company_id': companyId,
    };
  }

  ExpenseModel copyWith({
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
    return ExpenseModel(
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
}

enum ExpenseType {
  fuel('fuel', 'Fuel'),
  toll('toll', 'Toll/Péages'),
  customs('customs', 'Customs/Douane'),
  accommodation('accommodation', 'Accommodation/Hébergement'),
  meals('meals', 'Meals/Repas'),
  maintenance('maintenance', 'Maintenance'),
  insurance('insurance', 'Insurance'),
  parking('parking', 'Parking'),
  driverAllowance('driver_allowance', 'Driver Allowance'),
  other('other', 'Other');

  const ExpenseType(this.value, this.displayName);

  final String value;
  final String displayName;

  static ExpenseType fromString(String value) {
    return ExpenseType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ExpenseType.other,
    );
  }
}