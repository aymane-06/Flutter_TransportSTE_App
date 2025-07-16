import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/api_service.dart';
import '../models/report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ReportsRepo {
  Future<Either<Failure, List<DriverReport>>> getDriverReports({
    String? searchQuery,
    ReportType? reportType,
    ReportState? state,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, DriverReport>> getDriverReport(String reportId);

  Future<Either<Failure, DriverReport>> createDriverReport(DriverReport report);

  Future<Either<Failure, DriverReport>> updateDriverReport(DriverReport report);

  Future<Either<Failure, Unit>> deleteDriverReport(String reportId);

  Future<Either<Failure, Unit>> submitReport(String reportId);

  Future<Either<Failure, Unit>> acknowledgeReport(String reportId);

  Future<Either<Failure, Unit>> startProgress(String reportId);

  Future<Either<Failure, Unit>> resolveReport(
    String reportId,
    String resolutionNotes,
  );

  Future<Either<Failure, Unit>> closeReport(String reportId);
}

class ReportsRepoImp extends ReportsRepo {
  ReportsRepoImp({
    required ApiService apiService,
    required SharedPreferences preferences,
  }) : _apiService = apiService,
       _preferences = preferences;

  final ApiService _apiService;
  final SharedPreferences _preferences;

  @override
  Future<Either<Failure, List<DriverReport>>> getDriverReports({
    String? searchQuery,
    ReportType? reportType,
    ReportState? state,
    int? limit,
    int? offset,
  }) async {
    try {
      print('Loading driver reports...');
      final userId = _preferences.getInt('user_id');
      if (userId == null) {
        print('User ID not found in preferences');
        return Left(ServerFailure(message: 'Utilisateur non trouvé'));
      }
      print('User ID found: $userId');

      // Build domain filters
      List<List<dynamic>> domain = [
        ['driver_id.user_id', '=', userId],
      ];

      if (searchQuery != null && searchQuery.isNotEmpty) {
        domain.add(['|']);
        domain.add(['subject', 'ilike', searchQuery]);
        domain.add(['description', 'ilike', searchQuery]);
      }

      if (reportType != null) {
        domain.add(['report_type', '=', reportType.value]);
      }

      if (state != null) {
        domain.add(['state', '=', state.value]);
      }

      print('Domain filters: $domain');

      final params = {
        'model': 'transport.driver.report',
        'method': 'search_read',
        'args': [domain],
        'kwargs': {
          'fields': [
            'id',
            'name',
            'report_date',
            'driver_id',
            'trip_id',
            'vehicle_id',
            'report_type',
            'priority',
            'subject',
            'description',
            'location',
            'country_id',
            'state',
            'acknowledged_by',
            'acknowledged_date',
            'resolved_by',
            'resolved_date',
            'resolution_notes',
            'weather_conditions',
            'witnesses',
            'police_report',
            'police_report_number',
            'insurance_claim',
            'insurance_claim_number',
            'attachment_ids',
            'days_since_report',
          ],
          'limit': limit ?? 50,
          'offset': offset ?? 0,
          'order': 'report_date desc',
        },
      };

      print('API request params: $params');

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: params,
      );

      print('API response success: ${apiRes.isSuccess}');
      if (apiRes.data != null) {
        print('API response data: ${apiRes.data!.data}');
      }

      if (apiRes.isSuccess && apiRes.data != null) {
        final List<dynamic> data = apiRes.data!.data['result'] ?? [];
        print('Found ${data.length} reports');

        final List<DriverReport> reports = [];
        for (int i = 0; i < data.length; i++) {
          try {
            print('Parsing report ${i + 1}: ${data[i]}');
            final report = DriverReport.fromJson(data[i]);
            reports.add(report);
          } catch (e) {
            print('Error parsing report ${i + 1}: $e');
            print('Report data: ${data[i]}');
          }
        }

        print('Successfully parsed ${reports.length} reports');
        return Right(reports);
      } else {
        print('API call failed or no data returned');
        return Left(
          ServerFailure(message: 'Erreur lors du chargement des rapports'),
        );
      }
    } catch (e) {
      print('Exception in getDriverReports: $e');
      return Left(
        ServerFailure(
          message: 'Erreur lors du chargement des rapports: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DriverReport>> getDriverReport(String reportId) async {
    try {
      final params = {
        'model': 'transport.driver.report',
        'method': 'read',
        'args': [int.parse(reportId)],
        'kwargs': {
          'fields': [
            'id',
            'name',
            'report_date',
            'driver_id',
            'trip_id',
            'vehicle_id',
            'report_type',
            'priority',
            'subject',
            'description',
            'location',
            'country_id',
            'state',
            'acknowledged_by',
            'acknowledged_date',
            'resolved_by',
            'resolved_date',
            'resolution_notes',
            'weather_conditions',
            'witnesses',
            'police_report',
            'police_report_number',
            'insurance_claim',
            'insurance_claim_number',
            'attachment_ids',
            'days_since_report',
          ],
        },
      };

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: params,
      );

      if (apiRes.isSuccess && apiRes.data != null) {
        final data = apiRes.data!.data['result'];
        if (data != null && data.isNotEmpty) {
          final report = DriverReport.fromJson(data[0]);
          return Right(report);
        } else {
          return Left(ServerFailure(message: 'Rapport non trouvé'));
        }
      } else {
        return Left(
          ServerFailure(message: 'Erreur lors du chargement du rapport'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Erreur lors du chargement du rapport: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DriverReport>> createDriverReport(
    DriverReport report,
  ) async {
    try {
      print('Creating driver report...');
      final userId = _preferences.getInt('user_id');
      if (userId == null) {
        print('User ID not found in preferences');
        return Left(ServerFailure(message: 'Utilisateur non trouvé'));
      }
      print('User ID found: $userId');

      // Since the chauffeur is the user, use the hr.employee model
      // But first check if there's already a driver record for this user
      final driverParams = {
        'model': 'hr.employee',
        'method': 'search_read',
        'args': [
          [
            ['user_id', '=', userId],
          ],
        ],
        'kwargs': {
          'fields': ['id', 'name'],
          'limit': 1,
        },
      };

      print('Searching for driver with params: $driverParams');
      final driverRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: driverParams,
      );

      print('Driver search response: ${driverRes.isSuccess}');
      if (driverRes.data != null) {
        print('Driver response data: ${driverRes.data!.data}');
      }

      if (!driverRes.isSuccess) {
        print('Driver search API failed');
        return Left(
          ServerFailure(message: 'Erreur lors de la recherche du chauffeur'),
        );
      }

      if (driverRes.data?.data == null) {
        print('Driver response data is null');
        return Left(ServerFailure(message: 'Réponse invalide du serveur'));
      }

      final result = driverRes.data!.data['result'];
      if (result == null || (result is List && result.isEmpty)) {
        print('Driver not found or empty result');
        return Left(ServerFailure(message: 'Chauffeur non trouvé'));
      }

      final driverId = result[0]['id'];
      print('Driver ID found: $driverId');

      // Create report data with proper formatting for Odoo18
      // Format datetime for Odoo: YYYY-MM-DD HH:MM:SS
      final formattedDate =
          '${report.reportDate.year.toString().padLeft(4, '0')}-'
          '${report.reportDate.month.toString().padLeft(2, '0')}-'
          '${report.reportDate.day.toString().padLeft(2, '0')} '
          '${report.reportDate.hour.toString().padLeft(2, '0')}:'
          '${report.reportDate.minute.toString().padLeft(2, '0')}:'
          '${report.reportDate.second.toString().padLeft(2, '0')}';

      final reportData = {
        'name': report.subject, // Use subject as name for Odoo
        'report_date': formattedDate,
        'driver_id': driverId,
        'report_type': report.reportType.value,
        'priority': report.priority.value,
        'subject': report.subject,
        'description': report.description,
        'state': 'submitted', // Start as submitted instead of draft
      };

      // Add optional fields only if they have values
      if (report.location != null && report.location!.isNotEmpty) {
        reportData['location'] = report.location!;
      }
      if (report.weatherConditions != null &&
          report.weatherConditions!.isNotEmpty) {
        reportData['weather_conditions'] = report.weatherConditions!;
      }
      if (report.witnesses != null && report.witnesses!.isNotEmpty) {
        reportData['witnesses'] = report.witnesses!;
      }
      if (report.policeReport) {
        reportData['police_report'] = true;
        if (report.policeReportNumber != null &&
            report.policeReportNumber!.isNotEmpty) {
          reportData['police_report_number'] = report.policeReportNumber!;
        }
      }
      if (report.insuranceClaim) {
        reportData['insurance_claim'] = true;
        if (report.insuranceClaimNumber != null &&
            report.insuranceClaimNumber!.isNotEmpty) {
          reportData['insurance_claim_number'] = report.insuranceClaimNumber!;
        }
      }

      print('Report data to create: $reportData');

      final params = {
        'model': 'transport.driver.report',
        'method': 'create',
        'args': [reportData],
        'kwargs': {},
      };

      print('Creating report with params: $params');
      final apiRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: params,
      );

      print('Create report response: ${apiRes.isSuccess}');
      if (apiRes.data != null) {
        print('Create report response data: ${apiRes.data!.data}');
      }

      if (apiRes.isSuccess && apiRes.data != null) {
        final reportId = apiRes.data!.data['result'].toString();
        print('Report created successfully with ID: $reportId');
        return await getDriverReport(reportId);
      } else {
        print('Failed to create report');
        return Left(
          ServerFailure(message: 'Erreur lors de la création du rapport'),
        );
      }
    } catch (e) {
      print('Exception in createDriverReport: $e');
      return Left(
        ServerFailure(
          message: 'Erreur lors de la création du rapport: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DriverReport>> updateDriverReport(
    DriverReport report,
  ) async {
    try {
      if (report.id == null) {
        return Left(ServerFailure(message: 'ID du rapport manquant'));
      }

      final params = {
        'model': 'transport.driver.report',
        'method': 'write',
        'args': [int.parse(report.id!), report.toJson()],
        'kwargs': {},
      };

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: params,
      );

      if (apiRes.isSuccess) {
        return await getDriverReport(report.id!);
      } else {
        return Left(
          ServerFailure(message: 'Erreur lors de la mise à jour du rapport'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Erreur lors de la mise à jour du rapport: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDriverReport(String reportId) async {
    try {
      final params = {
        'model': 'transport.driver.report',
        'method': 'unlink',
        'args': [int.parse(reportId)],
        'kwargs': {},
      };

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: params,
      );

      if (apiRes.isSuccess) {
        return const Right(unit);
      } else {
        return Left(
          ServerFailure(message: 'Erreur lors de la suppression du rapport'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Erreur lors de la suppression du rapport: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> submitReport(String reportId) async {
    try {
      final params = {
        'model': 'transport.driver.report',
        'method': 'action_submit',
        'args': [int.parse(reportId)],
        'kwargs': {},
      };

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: params,
      );

      if (apiRes.isSuccess) {
        return const Right(unit);
      } else {
        return Left(
          ServerFailure(message: 'Erreur lors de la soumission du rapport'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Erreur lors de la soumission du rapport: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> acknowledgeReport(String reportId) async {
    try {
      final params = {
        'model': 'transport.driver.report',
        'method': 'action_acknowledge',
        'args': [int.parse(reportId)],
        'kwargs': {},
      };

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: params,
      );

      if (apiRes.isSuccess) {
        return const Right(unit);
      } else {
        return Left(
          ServerFailure(message: 'Erreur lors de l\'accusé de réception'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Erreur lors de l\'accusé de réception: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> startProgress(String reportId) async {
    try {
      final params = {
        'model': 'transport.driver.report',
        'method': 'action_start_progress',
        'args': [int.parse(reportId)],
        'kwargs': {},
      };

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: params,
      );

      if (apiRes.isSuccess) {
        return const Right(unit);
      } else {
        return Left(
          ServerFailure(message: 'Erreur lors du démarrage du traitement'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Erreur lors du démarrage du traitement: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> resolveReport(
    String reportId,
    String resolutionNotes,
  ) async {
    try {
      final params = {
        'model': 'transport.driver.report',
        'method': 'write',
        'args': [
          int.parse(reportId),
          {'resolution_notes': resolutionNotes},
        ],
        'kwargs': {},
      };

      final writeRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: params,
      );

      if (writeRes.isSuccess) {
        final resolveParams = {
          'model': 'transport.driver.report',
          'method': 'action_resolve',
          'args': [int.parse(reportId)],
          'kwargs': {},
        };

        final resolveRes = await _apiService.post(
          '/web/dataset/call_kw',
          params: resolveParams,
        );

        if (resolveRes.isSuccess) {
          return const Right(unit);
        } else {
          return Left(
            ServerFailure(message: 'Erreur lors de la résolution du rapport'),
          );
        }
      } else {
        return Left(
          ServerFailure(message: 'Erreur lors de la mise à jour des notes'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Erreur lors de la résolution du rapport: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> closeReport(String reportId) async {
    try {
      final params = {
        'model': 'transport.driver.report',
        'method': 'action_close',
        'args': [int.parse(reportId)],
        'kwargs': {},
      };

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw',
        params: params,
      );

      if (apiRes.isSuccess) {
        return const Right(unit);
      } else {
        return Left(
          ServerFailure(message: 'Erreur lors de la fermeture du rapport'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Erreur lors de la fermeture du rapport: ${e.toString()}',
        ),
      );
    }
  }
}
