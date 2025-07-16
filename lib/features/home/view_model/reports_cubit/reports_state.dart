part of 'reports_cubit.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<DriverReport> allReports;
  final List<DriverReport> filteredReports;
  final String? searchQuery;
  final ReportType? selectedType;
  final ReportState? selectedState;

  const ReportsLoaded({
    required this.allReports,
    required this.filteredReports,
    this.searchQuery,
    this.selectedType,
    this.selectedState,
  });

  @override
  List<Object?> get props => [
    allReports,
    filteredReports,
    searchQuery,
    selectedType,
    selectedState,
  ];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReportCreating extends ReportsState {}

class ReportCreated extends ReportsState {
  final DriverReport report;

  const ReportCreated({required this.report});

  @override
  List<Object?> get props => [report];
}

class ReportCreationError extends ReportsState {
  final String message;

  const ReportCreationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReportUpdating extends ReportsState {}

class ReportUpdated extends ReportsState {
  final DriverReport report;

  const ReportUpdated({required this.report});

  @override
  List<Object?> get props => [report];
}

class ReportUpdateError extends ReportsState {
  final String message;

  const ReportUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReportSubmitting extends ReportsState {}

class ReportSubmitted extends ReportsState {
  final String reportId;

  const ReportSubmitted({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

class ReportSubmissionError extends ReportsState {
  final String message;

  const ReportSubmissionError({required this.message});

  @override
  List<Object?> get props => [message];
}
