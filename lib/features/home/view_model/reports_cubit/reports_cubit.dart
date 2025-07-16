import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../repository/reports_repo.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({required this.reportsRepo}) : super(ReportsInitial());

  final ReportsRepo reportsRepo;
  BuildContext? context;

  Future<void> loadReports({
    String? searchQuery,
    ReportType? reportType,
    ReportState? reportState,
  }) async {
    print(
      'ReportsCubit: loadReports called with searchQuery: $searchQuery, reportType: $reportType, reportState: $reportState',
    );
    emit(ReportsLoading());

    try {
      final result = await reportsRepo.getDriverReports(
        searchQuery: searchQuery,
        reportType: reportType,
        state: reportState,
      );

      result.fold(
        (failure) {
          print(
            'ReportsCubit: loadReports failed with error: ${failure.message}',
          );
          emit(ReportsError(message: failure.message));
        },
        (reports) {
          print(
            'ReportsCubit: loadReports succeeded with ${reports.length} reports',
          );
          final filteredReports = _filterReports(
            reports,
            reportType,
            reportState,
            searchQuery,
          );
          print(
            'ReportsCubit: After filtering, ${filteredReports.length} reports remain',
          );
          emit(
            ReportsLoaded(
              allReports: reports,
              filteredReports: filteredReports,
              searchQuery: searchQuery,
              selectedType: reportType,
              selectedState: reportState,
            ),
          );
        },
      );
    } catch (e) {
      print('ReportsCubit: loadReports exception: $e');
      emit(
        ReportsError(
          message: 'Une erreur est survenue lors du chargement des rapports',
        ),
      );
    }
  }

  void applyFilters({
    String? searchQuery,
    ReportType? reportType,
    ReportState? reportState,
  }) {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;

      final newQuery = searchQuery ?? currentState.searchQuery;
      final newType = reportType ?? currentState.selectedType;
      final newState = reportState ?? currentState.selectedState;

      final filteredReports = _filterReports(
        currentState.allReports,
        newType,
        newState,
        newQuery,
      );

      emit(
        ReportsLoaded(
          allReports: currentState.allReports,
          filteredReports: filteredReports,
          searchQuery: newQuery,
          selectedType: newType,
          selectedState: newState,
        ),
      );
    }
  }

  List<DriverReport> _filterReports(
    List<DriverReport> reports,
    ReportType? reportType,
    ReportState? reportState,
    String? searchQuery,
  ) {
    return reports.where((report) {
      // Type filter
      final matchesType = reportType == null || report.reportType == reportType;

      // State filter
      final matchesState = reportState == null || report.state == reportState;

      // Search query filter
      final matchesQuery =
          searchQuery == null ||
          searchQuery.isEmpty ||
          report.subject.toLowerCase().contains(searchQuery.toLowerCase()) ||
          report.description.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          (report.location?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false);

      return matchesType && matchesState && matchesQuery;
    }).toList();
  }

  Future<void> createReport(DriverReport report) async {
    emit(ReportCreating());

    try {
      final result = await reportsRepo.createDriverReport(report);

      result.fold(
        (failure) => emit(ReportCreationError(message: failure.message)),
        (createdReport) {
          emit(ReportCreated(report: createdReport));
          // Refresh the reports list
          refreshReports();
        },
      );
    } catch (e) {
      emit(
        ReportCreationError(
          message: 'Une erreur est survenue lors de la création du rapport',
        ),
      );
    }
  }

  Future<void> updateReport(DriverReport report) async {
    emit(ReportUpdating());

    try {
      final result = await reportsRepo.updateDriverReport(report);

      result.fold(
        (failure) => emit(ReportUpdateError(message: failure.message)),
        (updatedReport) {
          emit(ReportUpdated(report: updatedReport));
          // Refresh the reports list
          refreshReports();
        },
      );
    } catch (e) {
      emit(
        ReportUpdateError(
          message: 'Une erreur est survenue lors de la mise à jour du rapport',
        ),
      );
    }
  }

  Future<void> submitReport(String reportId) async {
    emit(ReportSubmitting());

    try {
      final result = await reportsRepo.submitReport(reportId);

      result.fold(
        (failure) => emit(ReportSubmissionError(message: failure.message)),
        (_) {
          emit(ReportSubmitted(reportId: reportId));
          // Refresh the reports list
          refreshReports();
        },
      );
    } catch (e) {
      emit(
        ReportSubmissionError(
          message: 'Une erreur est survenue lors de la soumission du rapport',
        ),
      );
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      final result = await reportsRepo.deleteDriverReport(reportId);

      result.fold((failure) => emit(ReportsError(message: failure.message)), (
        _,
      ) {
        // Refresh the reports list
        refreshReports();
      });
    } catch (e) {
      emit(
        ReportsError(
          message: 'Une erreur est survenue lors de la suppression du rapport',
        ),
      );
    }
  }

  Future<void> refreshReports() async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      await loadReports(
        searchQuery: currentState.searchQuery,
        reportType: currentState.selectedType,
        reportState: currentState.selectedState,
      );
    } else {
      await loadReports();
    }
  }

  void clearFilters() {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      emit(
        ReportsLoaded(
          allReports: currentState.allReports,
          filteredReports: currentState.allReports,
          searchQuery: null,
          selectedType: null,
          selectedState: null,
        ),
      );
    }
  }

  void showMessage(String message, {bool isError = false}) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
