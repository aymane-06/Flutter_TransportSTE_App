import 'package:equatable/equatable.dart';

enum ReportType {
  incident,
  accident,
  maintenance,
  fuel,
  customer,
  route,
  security,
  other,
}

enum ReportPriority { low, medium, high, urgent }

enum ReportState {
  draft,
  submitted,
  acknowledged,
  inProgress,
  resolved,
  closed,
}

extension ReportTypeExtension on ReportType {
  String get name {
    switch (this) {
      case ReportType.incident:
        return 'Incident';
      case ReportType.accident:
        return 'Accident';
      case ReportType.maintenance:
        return 'Problème de maintenance';
      case ReportType.fuel:
        return 'Rapport de carburant';
      case ReportType.customer:
        return 'Problème client';
      case ReportType.route:
        return 'Problème de route';
      case ReportType.security:
        return 'Problème de sécurité';
      case ReportType.other:
        return 'Autre';
    }
  }

  String get value {
    switch (this) {
      case ReportType.incident:
        return 'incident';
      case ReportType.accident:
        return 'accident';
      case ReportType.maintenance:
        return 'maintenance';
      case ReportType.fuel:
        return 'fuel';
      case ReportType.customer:
        return 'customer';
      case ReportType.route:
        return 'route';
      case ReportType.security:
        return 'security';
      case ReportType.other:
        return 'other';
    }
  }
}

extension ReportPriorityExtension on ReportPriority {
  String get name {
    switch (this) {
      case ReportPriority.low:
        return 'Faible';
      case ReportPriority.medium:
        return 'Moyen';
      case ReportPriority.high:
        return 'Élevé';
      case ReportPriority.urgent:
        return 'Urgent';
    }
  }

  String get value {
    switch (this) {
      case ReportPriority.low:
        return 'low';
      case ReportPriority.medium:
        return 'medium';
      case ReportPriority.high:
        return 'high';
      case ReportPriority.urgent:
        return 'urgent';
    }
  }
}

extension ReportStateExtension on ReportState {
  String get name {
    switch (this) {
      case ReportState.draft:
        return 'Brouillon';
      case ReportState.submitted:
        return 'Soumis';
      case ReportState.acknowledged:
        return 'Accusé de réception';
      case ReportState.inProgress:
        return 'En cours';
      case ReportState.resolved:
        return 'Résolu';
      case ReportState.closed:
        return 'Fermé';
    }
  }

  String get value {
    switch (this) {
      case ReportState.draft:
        return 'draft';
      case ReportState.submitted:
        return 'submitted';
      case ReportState.acknowledged:
        return 'acknowledged';
      case ReportState.inProgress:
        return 'in_progress';
      case ReportState.resolved:
        return 'resolved';
      case ReportState.closed:
        return 'closed';
    }
  }
}

class DriverReport extends Equatable {
  final String? id;
  final String? name;
  final DateTime reportDate;
  final String driverId;
  final String? driverName;
  final String? tripId;
  final String? tripName;
  final String? vehicleId;
  final String? vehicleName;
  final ReportType reportType;
  final ReportPriority priority;
  final String subject;
  final String description;
  final String? location;
  final String? countryId;
  final String? countryName;
  final ReportState state;
  final String? acknowledgedBy;
  final DateTime? acknowledgedDate;
  final String? resolvedBy;
  final DateTime? resolvedDate;
  final String? resolutionNotes;
  final String? weatherConditions;
  final String? witnesses;
  final bool policeReport;
  final String? policeReportNumber;
  final bool insuranceClaim;
  final String? insuranceClaimNumber;
  final List<String> attachmentIds;
  final int? daysSinceReport;

  const DriverReport({
    this.id,
    this.name,
    required this.reportDate,
    required this.driverId,
    this.driverName,
    this.tripId,
    this.tripName,
    this.vehicleId,
    this.vehicleName,
    required this.reportType,
    required this.priority,
    required this.subject,
    required this.description,
    this.location,
    this.countryId,
    this.countryName,
    this.state = ReportState.draft,
    this.acknowledgedBy,
    this.acknowledgedDate,
    this.resolvedBy,
    this.resolvedDate,
    this.resolutionNotes,
    this.weatherConditions,
    this.witnesses,
    this.policeReport = false,
    this.policeReportNumber,
    this.insuranceClaim = false,
    this.insuranceClaimNumber,
    this.attachmentIds = const [],
    this.daysSinceReport,
  });

  factory DriverReport.fromJson(Map<String, dynamic> json) {
    return DriverReport(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      reportDate: DateTime.parse(json['report_date']),
      driverId: json['driver_id'] is List
          ? json['driver_id'][0].toString()
          : json['driver_id'].toString(),
      driverName: json['driver_id'] is List
          ? json['driver_id'][1]?.toString()
          : null,
      tripId: json['trip_id'] is List
          ? json['trip_id'][0].toString()
          : json['trip_id']?.toString(),
      tripName: json['trip_id'] is List ? json['trip_id'][1]?.toString() : null,
      vehicleId: json['vehicle_id'] is List
          ? json['vehicle_id'][0].toString()
          : json['vehicle_id']?.toString(),
      vehicleName: json['vehicle_id'] is List
          ? json['vehicle_id'][1]?.toString()
          : null,
      reportType: ReportType.values.firstWhere(
        (type) => type.value == json['report_type'],
        orElse: () => ReportType.other,
      ),
      priority: ReportPriority.values.firstWhere(
        (priority) => priority.value == json['priority'],
        orElse: () => ReportPriority.medium,
      ),
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString(),
      countryId: json['country_id'] is List
          ? json['country_id'][0].toString()
          : json['country_id']?.toString(),
      countryName: json['country_id'] is List
          ? json['country_id'][1]?.toString()
          : null,
      state: ReportState.values.firstWhere(
        (state) => state.value == json['state'],
        orElse: () => ReportState.draft,
      ),
      acknowledgedBy: json['acknowledged_by'] is List
          ? json['acknowledged_by'][1]?.toString()
          : json['acknowledged_by']?.toString(),
      acknowledgedDate:
          json['acknowledged_date'] != null &&
              json['acknowledged_date'] != false
          ? DateTime.parse(json['acknowledged_date'])
          : null,
      resolvedBy: json['resolved_by'] is List
          ? json['resolved_by'][1]?.toString()
          : json['resolved_by']?.toString(),
      resolvedDate:
          json['resolved_date'] != null && json['resolved_date'] != false
          ? DateTime.parse(json['resolved_date'])
          : null,
      resolutionNotes:
          json['resolution_notes'] != null && json['resolution_notes'] != false
          ? json['resolution_notes'].toString()
          : null,
      weatherConditions:
          json['weather_conditions'] != null &&
              json['weather_conditions'] != false
          ? json['weather_conditions'].toString()
          : null,
      witnesses: json['witnesses'] != null && json['witnesses'] != false
          ? json['witnesses'].toString()
          : null,
      policeReport: json['police_report'] == true,
      policeReportNumber:
          json['police_report_number'] != null &&
              json['police_report_number'] != false
          ? json['police_report_number'].toString()
          : null,
      insuranceClaim: json['insurance_claim'] == true,
      insuranceClaimNumber:
          json['insurance_claim_number'] != null &&
              json['insurance_claim_number'] != false
          ? json['insurance_claim_number'].toString()
          : null,
      attachmentIds:
          (json['attachment_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      daysSinceReport: json['days_since_report'] is int
          ? json['days_since_report']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': int.tryParse(id!) ?? id,
      'name': name,
      'report_date': reportDate.toIso8601String(),
      'driver_id': int.tryParse(driverId) ?? driverId,
      if (tripId != null) 'trip_id': int.tryParse(tripId!) ?? tripId,
      if (vehicleId != null)
        'vehicle_id': int.tryParse(vehicleId!) ?? vehicleId,
      'report_type': reportType.value,
      'priority': priority.value,
      'subject': subject,
      'description': description,
      if (location != null) 'location': location,
      if (countryId != null)
        'country_id': int.tryParse(countryId!) ?? countryId,
      'state': state.value,
      if (acknowledgedBy != null) 'acknowledged_by': acknowledgedBy,
      if (acknowledgedDate != null)
        'acknowledged_date': acknowledgedDate!.toIso8601String(),
      if (resolvedBy != null) 'resolved_by': resolvedBy,
      if (resolvedDate != null)
        'resolved_date': resolvedDate!.toIso8601String(),
      if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
      if (weatherConditions != null) 'weather_conditions': weatherConditions,
      if (witnesses != null) 'witnesses': witnesses,
      'police_report': policeReport,
      if (policeReportNumber != null)
        'police_report_number': policeReportNumber,
      'insurance_claim': insuranceClaim,
      if (insuranceClaimNumber != null)
        'insurance_claim_number': insuranceClaimNumber,
      'attachment_ids': attachmentIds
          .map((id) => int.tryParse(id) ?? id)
          .toList(),
    };
  }

  DriverReport copyWith({
    String? id,
    String? name,
    DateTime? reportDate,
    String? driverId,
    String? driverName,
    String? tripId,
    String? tripName,
    String? vehicleId,
    String? vehicleName,
    ReportType? reportType,
    ReportPriority? priority,
    String? subject,
    String? description,
    String? location,
    String? countryId,
    String? countryName,
    ReportState? state,
    String? acknowledgedBy,
    DateTime? acknowledgedDate,
    String? resolvedBy,
    DateTime? resolvedDate,
    String? resolutionNotes,
    String? weatherConditions,
    String? witnesses,
    bool? policeReport,
    String? policeReportNumber,
    bool? insuranceClaim,
    String? insuranceClaimNumber,
    List<String>? attachmentIds,
    int? daysSinceReport,
  }) {
    return DriverReport(
      id: id ?? this.id,
      name: name ?? this.name,
      reportDate: reportDate ?? this.reportDate,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      tripId: tripId ?? this.tripId,
      tripName: tripName ?? this.tripName,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      reportType: reportType ?? this.reportType,
      priority: priority ?? this.priority,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      location: location ?? this.location,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      state: state ?? this.state,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedDate: acknowledgedDate ?? this.acknowledgedDate,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      witnesses: witnesses ?? this.witnesses,
      policeReport: policeReport ?? this.policeReport,
      policeReportNumber: policeReportNumber ?? this.policeReportNumber,
      insuranceClaim: insuranceClaim ?? this.insuranceClaim,
      insuranceClaimNumber: insuranceClaimNumber ?? this.insuranceClaimNumber,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      daysSinceReport: daysSinceReport ?? this.daysSinceReport,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    reportDate,
    driverId,
    driverName,
    tripId,
    tripName,
    vehicleId,
    vehicleName,
    reportType,
    priority,
    subject,
    description,
    location,
    countryId,
    countryName,
    state,
    acknowledgedBy,
    acknowledgedDate,
    resolvedBy,
    resolvedDate,
    resolutionNotes,
    weatherConditions,
    witnesses,
    policeReport,
    policeReportNumber,
    insuranceClaim,
    insuranceClaimNumber,
    attachmentIds,
    daysSinceReport,
  ];
}
