class TripRevenue {
  final String? id;
  final String tripId;
  final String name;
  final String? revenueType;
  final double amount;
  final String? currencyId;
  final DateTime date;
  final String? customer;
  final String? invoiceNumber;
  final String? notes;
  final String companyId;

  TripRevenue({
    this.id,
    required this.tripId,
    required this.name,
    this.revenueType,
    required this.amount,
    this.currencyId,
    required this.date,
    this.customer,
    this.invoiceNumber,
    this.notes,
    required this.companyId,
  });

  factory TripRevenue.fromJson(Map<String, dynamic> json) {
    print('Parsing TripRevenue from JSON: $json');

    // Helper function to extract ID from Many2one field
    String? extractMany2oneId(dynamic field) {
      if (field == null || field == false) return null;
      if (field is List && field.isNotEmpty) {
        return field[0].toString();
      }
      return field.toString();
    }

    try {
      return TripRevenue(
        id: json['id']?.toString(),
        tripId: extractMany2oneId(json['trip_id']) ?? '',
        name: json['name'] ?? 'Unknown Revenue',
        revenueType: json['revenue_type'],
        amount: json['amount']?.toDouble() ?? 0.0,
        currencyId: extractMany2oneId(json['currency_id']),
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
        customer: json['customer'],
        invoiceNumber: json['invoice_number'],
        notes: json['notes'],
        companyId: extractMany2oneId(json['company_id']) ?? '',
      );
    } catch (e) {
      print('Error parsing TripRevenue from JSON: $e');
      print('JSON data: $json');

      // Return a default revenue if parsing fails
      return TripRevenue(
        id: json['id']?.toString(),
        tripId: '',
        name: json['name'] ?? 'Unknown Revenue',
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
      'revenue_type': revenueType,
      'amount': amount,
      'currency_id': currencyId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'customer': customer,
      'invoice_number': invoiceNumber,
      'notes': notes,
      'company_id': companyId,
    };
  }

  TripRevenue copyWith({
    String? id,
    String? tripId,
    String? name,
    String? revenueType,
    double? amount,
    String? currencyId,
    DateTime? date,
    String? customer,
    String? invoiceNumber,
    String? notes,
    String? companyId,
  }) {
    return TripRevenue(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      revenueType: revenueType ?? this.revenueType,
      amount: amount ?? this.amount,
      currencyId: currencyId ?? this.currencyId,
      date: date ?? this.date,
      customer: customer ?? this.customer,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      notes: notes ?? this.notes,
      companyId: companyId ?? this.companyId,
    );
  }
}
