import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/constants.dart' as app_constants;
import '../models/user_model.dart';
import '../models/dashboard_model.dart';
import '../models/trip_model.dart';
import '../models/expense_model.dart';
import '../models/revenue_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class HomeRepo {
  Future<Either<Failure, UserModel>> getUserProfile();
  Future<Either<Failure, DashboardStatsModel>> getDashboardStats();
  Future<Either<Failure, List<Trip>>> getUserTrips();
  Future<Either<Failure, Unit>> updateUserProfile(UserModel user);
  Future<Either<Failure, List<TripExpense>>> getTripExpenses(String tripId);
  Future<Either<Failure, List<TripRevenue>>> getTripRevenues(String tripId);
}

class HomeRepoImp extends HomeRepo {
  HomeRepoImp({
    required ApiService apiService,
    required SharedPreferences preferences,
  }) : _apiService = apiService,
       _preferences = preferences;

  final ApiService _apiService;
  final SharedPreferences _preferences;

  @override
  Future<Either<Failure, UserModel>> getUserProfile() async {
    try {
      final userId = _preferences.getInt('user_id');
      if (userId == null) {
        return Left(ServerFailure(message: 'Utilisateur non trouvé'));
      }

      // For Odoo 18, use the correct API endpoint
      final apiRes = await _apiService.post(
        '/web/dataset/call_kw/res.users/read',
        params: {
          'model': 'res.users',
          'method': 'read',
          'args': [
            [userId],
            ['id', 'name', 'login', 'email', 'image_1920', 'groups_id'],
          ],
          'kwargs': {},
        },
      );

      if (!apiRes.isSuccess) {
        return Left(
          ServerFailure(
            message:
                apiRes.error?.message ??
                app_constants.ResponseMessage.defaultError,
          ),
        );
      }

      final response = apiRes.data!;

      // For Odoo 18, the response structure is usually in response.data['result']
      final userData = response.data['result'];

      if (userData == null || (userData is List && userData.isEmpty)) {
        return Left(ServerFailure(message: 'Profil utilisateur non trouvé'));
      }

      // userData should be a list with one user object
      final userJson = userData is List ? userData[0] : userData;

      final user = UserModel.fromJson(userJson);
      return Right(user);
    } catch (e) {
      return Left(
        ServerFailure(message: app_constants.ResponseMessage.defaultError),
      );
    }
  }

  @override
  Future<Either<Failure, DashboardStatsModel>> getDashboardStats() async {
    try {
      final userId = _preferences.getInt('user_id');
      if (userId == null) {
        return Left(ServerFailure(message: 'Utilisateur non trouvé'));
      }

      // First, let's try to fetch trips for the current user
      final tripsResult = await _fetchUserTrips(userId);
      // Use fetched data if successful, otherwise fall back to mock data
      if (tripsResult['success'] == true) {
        return Right(
          DashboardStatsModel(
            totalTrips: tripsResult['totalTrips'] ?? 0,
            ongoingTrips: tripsResult['pendingTrips'] ?? 0,
            completedTrips: tripsResult['completedTrips'] ?? 0,
            totalExpenses: tripsResult['totalExpenses'] ?? 0.0,
            recentActivities: tripsResult['activities'] ?? [],
          ),
        );
      }

      // Return mock stats for driver dashboard as fallback
      return Right(
        DashboardStatsModel(
          totalTrips: 5,
          ongoingTrips: 2,
          completedTrips: 3,
          totalExpenses: 450.0,
          recentActivities: [
            RecentActivityModel(
              id: 1,
              title: 'Voyage terminé',
              description: 'Livraison à Paris terminée avec succès',
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
              type: 'trip',
            ),
            RecentActivityModel(
              id: 2,
              title: 'Dépense ajoutée',
              description: 'Carburant - 45€',
              createdAt: DateTime.now().subtract(const Duration(hours: 4)),
              type: 'expense',
            ),
            RecentActivityModel(
              id: 3,
              title: 'Nouveau voyage',
              description: 'Voyage vers Lyon assigné',
              createdAt: DateTime.now().subtract(const Duration(hours: 6)),
              type: 'trip',
            ),
          ],
        ),
      );
    } catch (e) {
      // Return default stats on error
      return Right(
        DashboardStatsModel(
          totalTrips: 0,
          ongoingTrips: 0,
          completedTrips: 0,
          totalExpenses: 0.0,
          recentActivities: [],
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUserProfile(UserModel user) async {
    try {
      final userId = _preferences.getInt('user_id');
      if (userId == null) {
        return Left(ServerFailure(message: 'Utilisateur non trouvé'));
      }

      // For Odoo 18, use the correct write method
      final apiRes = await _apiService.post(
        '/web/dataset/call_kw/res.users/write',
        params: {
          'model': 'res.users',
          'method': 'write',
          'args': [
            [userId],
            {'name': user.name, 'email': user.email},
          ],
          'kwargs': {},
        },
      );

      print('Update profile API response: ${apiRes.isSuccess}');

      if (!apiRes.isSuccess) {
        print('Update profile error: ${apiRes.error?.message}');
        return Left(
          ServerFailure(
            message:
                apiRes.error?.message ??
                app_constants.ResponseMessage.defaultError,
          ),
        );
      }

      return const Right(unit);
    } catch (e) {
      return Left(
        ServerFailure(message: app_constants.ResponseMessage.defaultError),
      );
    }
  }

  @override
  Future<Either<Failure, List<Trip>>> getUserTrips() async {
    try {
      final userId = _preferences.getInt('user_id');
      if (userId == null) {
        return Left(ServerFailure(message: 'Utilisateur non trouvé'));
      }

      // First, try to get the employee ID associated with this user
      final employeeRes = await _apiService.post(
        '/web/dataset/call_kw/hr.employee/search_read',
        params: {
          'model': 'hr.employee',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['user_id', '=', userId],
            ],
            'fields': ['id'],
            'limit': 1,
          },
        },
      );

      int? employeeId;
      if (employeeRes.isSuccess) {
        final employeeData = employeeRes.data!.data['result'] as List? ?? [];
        if (employeeData.isNotEmpty) {
          employeeId = employeeData[0]['id'] as int?;
          print('Found employee ID for user: $employeeId');
        }
      }

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw/transport.trip/search_read',
        params: {
          'model': 'transport.trip',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': employeeId != null
                ? [
                    ['driver_id', '=', employeeId],
                  ]
                : [
                    '|',
                    ['driver_id.user_id', '=', userId],
                    ['user_id', '=', userId],
                  ],
            'fields': [
              'id',
              'name',
              'state',
              'trip_type',
              'departure_city',
              'destination_city',
              'departure_country_id',
              'destination_country_id',
              'departure_date',
              'arrival_date',
              'actual_arrival_date',
              'return_date',
              'vehicle_id',
              'driver_id',
              'co_driver_id',
              'service_type',
              'cargo_description',
              'cargo_weight',
              'passenger_count',
              'revenue_ids',
              'expense_ids',
              'total_revenue',
              'total_expenses',
              'profit',
              'profit_margin',
              'currency_id',
              'notes',
              'distance_km',
              'fuel_consumption',
              'duration_days',
              'trailer_id',
              'company_id',
              'create_date',
            ],
            'order': 'create_date desc',
          },
        },
      );

      print('Get trips API response: ${apiRes.isSuccess}');

      if (!apiRes.isSuccess) {
        print('API Error: ${apiRes.error?.message}');
        return Left(
          ServerFailure(
            message:
                apiRes.error?.message ??
                app_constants.ResponseMessage.defaultError,
          ),
        );
      }

      final response = apiRes.data!;
      print('Trips response data: ${response.data}');

      final tripsData = response.data['result'] as List? ?? [];
      print('Found ${tripsData.length} trips');

      // Convert to List<Trip> using the existing Trip model
      final trips = tripsData
          .map((tripJson) {
            try {
              return Trip.fromJson(tripJson as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing trip: $e');
              print('Trip JSON: $tripJson');
              // Return a default trip or skip this one
              return null;
            }
          })
          .where((trip) => trip != null)
          .cast<Trip>()
          .toList();
          print(trips);

      print('Successfully parsed ${trips.length} trips');
      return Right(trips);
    } catch (e, stackTrace) {
      print('Error getting user trips: $e');
      print('Stack trace: $stackTrace');
      return Left(
        ServerFailure(message: app_constants.ResponseMessage.defaultError),
      );
    }
  }

  @override
  Future<Either<Failure, List<TripExpense>>> getTripExpenses(
    String tripId,
  ) async {
    try {
      print('Fetching expenses for trip: $tripId');

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw/transport.trip.expense/search_read',
        params: {
          'model': 'transport.trip.expense',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['trip_id', '=', int.parse(tripId)],
            ],
            'fields': [
              'id',
              'trip_id',
              'name',
              'expense_type',
              'amount',
              'currency_id',
              'date',
              'location',
              'supplier',
              'receipt_number',
              'notes',
              'vehicle_id',
              'driver_id',
              'company_id',
            ],
            'order': 'date desc',
          },
        },
      );

      print('Get expenses API response: ${apiRes.isSuccess}');

      if (!apiRes.isSuccess) {
        print('API Error: ${apiRes.error?.message}');
        return Left(
          ServerFailure(
            message:
                apiRes.error?.message ??
                app_constants.ResponseMessage.defaultError,
          ),
        );
      }

      final response = apiRes.data!;
      print('Expenses response data: ${response.data}');

      final expensesData = response.data['result'] as List? ?? [];
      print('Found ${expensesData.length} expenses');

      // Convert to List<TripExpense>
      final expenses = expensesData
          .map((expenseJson) {
            try {
              return TripExpense.fromJson(expenseJson as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing expense: $e');
              print('Expense JSON: $expenseJson');
              return null;
            }
          })
          .where((expense) => expense != null)
          .cast<TripExpense>()
          .toList();

      print('Successfully parsed ${expenses.length} expenses');
      return Right(expenses);
    } catch (e, stackTrace) {
      print('Error getting trip expenses: $e');
      print('Stack trace: $stackTrace');
      return Left(
        ServerFailure(message: app_constants.ResponseMessage.defaultError),
      );
    }
  }

  @override
  Future<Either<Failure, List<TripRevenue>>> getTripRevenues(
    String tripId,
  ) async {
    try {
      print('Fetching revenues for trip: $tripId');

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw/transport.trip.revenue/search_read',
        params: {
          'model': 'transport.trip.revenue',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['trip_id', '=', int.parse(tripId)],
            ],
            'fields': [
              'id',
              'trip_id',
              'name',
              'revenue_type',
              'amount',
              'currency_id',
              'date',
              'customer',
              'invoice_number',
              'notes',
              'company_id',
            ],
            'order': 'date desc',
          },
        },
      );

      print('Get revenues API response: ${apiRes.isSuccess}');

      if (!apiRes.isSuccess) {
        print('API Error: ${apiRes.error?.message}');
        return Left(
          ServerFailure(
            message:
                apiRes.error?.message ??
                app_constants.ResponseMessage.defaultError,
          ),
        );
      }

      final response = apiRes.data!;
      print('Revenues response data: ${response.data}');

      final revenuesData = response.data['result'] as List? ?? [];
      print('Found ${revenuesData.length} revenues');

      // Convert to List<TripRevenue>
      final revenues = revenuesData
          .map((revenueJson) {
            try {
              return TripRevenue.fromJson(revenueJson as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing revenue: $e');
              print('Revenue JSON: $revenueJson');
              return null;
            }
          })
          .where((revenue) => revenue != null)
          .cast<TripRevenue>()
          .toList();

      print('Successfully parsed ${revenues.length} revenues');
      return Right(revenues);
    } catch (e, stackTrace) {
      print('Error getting trip revenues: $e');
      print('Stack trace: $stackTrace');
      return Left(
        ServerFailure(message: app_constants.ResponseMessage.defaultError),
      );
    }
  }

  // Helper method to fetch trips for a specific user
  Future<Map<String, dynamic>> _fetchUserTrips(int userId) async {
    try {
      // Try multiple search approaches
      List<List<List<dynamic>>> searchDomains = [
        // Approach 1: driver_id as hr.employee ID
        [
          ['driver_id', '=', userId],
        ],
        // Approach 2: Search by user_id field if it exists
        [
          ['user_id', '=', userId],
        ],
        // Approach 3: Search by related user field in driver
        [
          ['driver_id.user_id', '=', userId],
        ],
      ];

      for (int i = 0; i < searchDomains.length; i++) {
        final searchResult = await _apiService.post(
          '/web/dataset/call_kw/transport.trip/search_read',
          params: {
            'model': 'transport.trip',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'domain': searchDomains[i],
              'fields': [
                'id',
                'name',
                'state',
                'trip_type',
                'departure_city',
                'destination_city',
                'departure_country_id',
                'destination_country_id',
                'departure_date',
                'arrival_date',
                'actual_arrival_date',
                'return_date',
                'vehicle_id',
                'driver_id',
                'co_driver_id',
                'service_type',
                'cargo_description',
                'cargo_weight',
                'passenger_count',
                'revenue_ids',
                'expense_ids',
                'total_revenue',
                'total_expenses',
                'profit',
                'profit_margin',
                'currency_id',
                'notes',
                'distance_km',
                'fuel_consumption',
                'duration_days',
                'trailer_id',
                'company_id',
                'create_date',
              ],
              'order': 'create_date desc',
              'limit': 20,
            },
          },
        );

        if (searchResult.isSuccess && searchResult.data != null) {
          final response = searchResult.data!;
          final trips = response.data['result'] as List? ?? [];

          if (trips.isNotEmpty) {
            // Process the successful result using existing logic
            return _processTripsData(trips, userId);
          }
        }
      }

      return {
        'success': false,
        'error': 'No trips found for user $userId with any search method',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Helper method to process trips data
  Map<String, dynamic> _processTripsData(List<dynamic> trips, int userId) {
    // Calculate statistics from trips
    int totalTrips = trips.length;
    int completedTrips = trips.where((trip) => trip['state'] == 'done').length;
    int pendingTrips = trips
        .where(
          (trip) => trip['state'] == 'draft' || trip['state'] == 'in_progress',
        )
        .length;

    // Calculate total revenue from completed trips
    double totalRevenue = trips
        .where(
          (trip) => trip['state'] == 'done' && trip['total_revenue'] != null,
        )
        .fold(
          0.0,
          (sum, trip) => sum + (trip['total_revenue'] as num).toDouble(),
        );

    // Calculate total expenses from all trips
    double totalExpenses = trips
        .where((trip) => trip['total_expenses'] != null)
        .fold(
          0.0,
          (sum, trip) => sum + (trip['total_expenses'] as num).toDouble(),
        );

    // Create recent activities from trips
    List<RecentActivityModel>
    activities = trips.take(5).map<RecentActivityModel>((trip) {
      String title = '';
      String description = '';
      String type = 'trip';

      switch (trip['state']) {
        case 'done':
          title = 'Voyage terminé';
          description =
              'Voyage vers ${trip['destination_city'] ?? 'destination'} terminé';
          break;
        case 'in_progress':
          title = 'Voyage en cours';
          description =
              'Voyage vers ${trip['destination_city'] ?? 'destination'} en cours';
          break;
        default:
          title = 'Nouveau voyage';
          description =
              'Voyage vers ${trip['destination_city'] ?? 'destination'} assigné';
      }

      DateTime createdAt =
          DateTime.tryParse(trip['create_date'] ?? '') ?? DateTime.now();

      return RecentActivityModel(
        id: trip['id'] as int,
        title: title,
        description: description,
        createdAt: createdAt,
        type: type,
      );
    }).toList();

    return {
      'success': true,
      'totalTrips': totalTrips,
      'completedTrips': completedTrips,
      'pendingTrips': pendingTrips,
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'activities': activities,
    };
  }
}
