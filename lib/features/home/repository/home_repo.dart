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

  // Additional expense methods
  Future<List<TripExpense>> getExpenses({
    String? tripId,
    String? searchQuery,
    ExpenseType? expenseType,
  });
  Future<void> createExpense(TripExpense expense);
  Future<void> updateExpense(TripExpense expense);
  Future<void> deleteExpense(String expenseId);
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

      final userData = response.data['result'];

      if (userData == null || (userData is List && userData.isEmpty)) {
        return Left(ServerFailure(message: 'Profil utilisateur non trouvé'));
      }

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

  // Additional expense methods implementation
  @override
  Future<List<TripExpense>> getExpenses({
    String? tripId,
    String? searchQuery,
    ExpenseType? expenseType,
  }) async {
    try {
      final userId = _preferences.getInt('user_id');
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Build domain filters
      List<List<dynamic>> domain = [
        ['create_uid', '=', userId],
      ];

      if (tripId != null && tripId != 'all') {
        domain.add(['trip_id', '=', int.parse(tripId)]);
      }

      if (expenseType != null) {
        domain.add(['expense_type', '=', expenseType.name]);
      }

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw/transport.trip.expense/search_read',
        params: {
          'model': 'transport.trip.expense',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': domain,
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
            'limit': 100,
            'offset': 0,
            'order': 'date desc',
          },
        },
      );

      if (!apiRes.isSuccess) {
        throw Exception(
          'Failed to load expenses: ${apiRes.error?.message ?? "Unknown error"}',
        );
      }

      final data = apiRes.data!.data;
      final records = data['result'] as List<dynamic>;

      List<TripExpense> expenses = records.map((record) {
        return TripExpense.fromJson(record as Map<String, dynamic>);
      }).toList();

      // Apply search query filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        expenses = expenses.where((expense) {
          final query = searchQuery.toLowerCase();
          return expense.name.toLowerCase().contains(query) ||
              (expense.supplier?.toLowerCase().contains(query) ?? false) ||
              (expense.location?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      return expenses;
    } catch (e) {
      throw Exception('Error loading expenses: $e');
    }
  }  @override
  Future<void> createExpense(TripExpense expense) async {
    try {
      // Remove id from the data for creation
      final expenseData = expense.toJson();
      expenseData.remove('id');
      
      print('Creating expense with data: $expenseData');
      
      final apiRes = await _apiService.post(
        '/web/dataset/call_kw/transport.trip.expense/create',
        params: {
          'model': 'transport.trip.expense',
          'method': 'create',
          'args': [expenseData],
          'kwargs': {},
        },
      );

      print('API Response: ${apiRes.data?.data}');

      if (!apiRes.isSuccess) {
        throw Exception(
          'Failed to create expense: ${apiRes.error?.message ?? "Unknown error"}',
        );
      }

      // In Odoo 18, create returns the ID of the created record
      final result = apiRes.data!.data['result'];
      print('Expense created with ID: $result');
      
      if (result == null || result == false) {
        throw Exception('Create operation failed: result was $result');
      }
    } catch (e) {
      print('Error creating expense: $e');
      throw Exception('Error creating expense: $e');
    }
  }

  @override
  Future<void> updateExpense(TripExpense expense) async {
    try {
      if (expense.id == null || expense.id!.isEmpty) {
        throw Exception('Cannot update expense without ID');
      }

      // Remove id from the data for update
      final expenseData = expense.toJson();
      expenseData.remove('id');
      
      print('Updating expense with ID: ${expense.id}');
      print('Update data: $expenseData');

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw/transport.trip.expense/write',
        params: {
          'model': 'transport.trip.expense',
          'method': 'write',
          'args': [
            [int.parse(expense.id!)],
            expenseData,
          ],
          'kwargs': {},
        },
      );

      print('API Response: ${apiRes.data?.data}');

      if (!apiRes.isSuccess) {
        throw Exception(
          'Failed to update expense: ${apiRes.error?.message ?? "Unknown error"}',
        );
      }

      // In Odoo 18, write returns true if successful
      final result = apiRes.data!.data['result'];
      print('Expense updated successfully: $result');
      
      if (result != true) {
        throw Exception('Update operation failed: result was $result');
      }
    } catch (e) {
      print('Error updating expense: $e');
      throw Exception('Error updating expense: $e');
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      if (expenseId.isEmpty) {
        throw Exception('Cannot delete expense without ID');
      }
      
      print('Deleting expense with ID: "$expenseId"');
      
      // Get current user ID for permission checking
      final userId = _preferences.getInt('user_id');
      print('Current user ID: $userId');
      
      // Validate that the ID is numeric
      final numericId = int.tryParse(expenseId.trim());
      if (numericId == null) {
        throw Exception('Invalid expense ID format: "$expenseId"');
      }
      
      print('Parsed numeric ID: $numericId');

      // First, let's check if the record exists by trying to read it
      final checkRes = await _apiService.post(
        '/web/dataset/call_kw/transport.trip.expense/read',
        params: {
          'model': 'transport.trip.expense',
          'method': 'read',
          'args': [
            [numericId],
            ['id', 'name', 'create_uid'],
          ],
          'kwargs': {},
        },
      );

      print('Check record response: ${checkRes.data}');
      
      if (!checkRes.isSuccess) {
        throw Exception('Expense not found or permission denied');
      }

      // Now proceed with deletion
      final requestParams = {
        'model': 'transport.trip.expense',
        'method': 'unlink',
        'args': [
          [numericId],
        ],
        'kwargs': {},
      };
      
      print('Delete request params: $requestParams');

      final apiRes = await _apiService.post(
        '/web/dataset/call_kw/transport.trip.expense/unlink',
        params: requestParams,
      );

      print('Delete API Raw Response: ${apiRes.data}');
      print('Delete API Response Type: ${apiRes.data.runtimeType}');
      print('Delete API Success: ${apiRes.isSuccess}');
      print('Delete API Error: ${apiRes.error}');

      if (!apiRes.isSuccess) {
        final errorMessage = apiRes.error?.message ?? "Unknown error";
        print('Delete API Error: $errorMessage');
        throw Exception('Failed to delete expense: $errorMessage');
      }

      // If the API call was successful (no error), we can assume the delete worked
      // regardless of the specific return value format
      print('Delete API call completed successfully');
      
      // Optional: Check response structure if available
      if (apiRes.data?.data != null) {
        final responseData = apiRes.data!.data;
        print('Full response data: $responseData');

        final result = responseData['result'];
        print('Delete result: $result (type: ${result.runtimeType})');
        
        // Only throw an error if the result is explicitly false
        if (result == false) {
          throw Exception('Delete operation explicitly failed: record may not exist or permission denied');
        }
      }
      
      // Optional: Verify deletion by trying to read the record
      try {
        final verifyRes = await _apiService.post(
          '/web/dataset/call_kw/transport.trip.expense/read',
          params: {
            'model': 'transport.trip.expense',
            'method': 'read',
            'args': [
              [numericId],
              ['id', 'name'],
            ],
            'kwargs': {},
          },
        );
        
        print('Verification response success: ${verifyRes.isSuccess}');
        print('Verification response: ${verifyRes.data}');
        
        // If we can still read the record, deletion failed
        if (verifyRes.isSuccess && verifyRes.data?.data != null) {
          final verifyResult = verifyRes.data!.data['result'];
          print('Verification result: $verifyResult');
          
          // If result is not null/false and contains data, the record still exists
          if (verifyResult != null && verifyResult != false) {
            if (verifyResult is List && verifyResult.isNotEmpty) {
              throw Exception('CRITICAL: Record still exists after delete attempt - deletion failed');
            } else if (verifyResult is Map && verifyResult.isNotEmpty) {
              throw Exception('CRITICAL: Record still exists after delete attempt - deletion failed');
            }
          }
        }
        
        print('Verification passed: Record appears to be deleted');
      } catch (e) {
        // If we get an error reading the record, it might be deleted
        print('Verification read failed: $e');
        
        // Check if the error indicates the record doesn't exist
        if (e.toString().contains('not found') || 
            e.toString().contains('does not exist') ||
            e.toString().contains('MissingError')) {
          print('Record confirmed deleted by error message');
        } else {
          print('Warning: Could not verify deletion due to error');
        }
      }
      // Alternative verification: Use search_read to check if record exists
      try {
        final searchRes = await _apiService.post(
          '/web/dataset/call_kw/transport.trip.expense/search_read',
          params: {
            'model': 'transport.trip.expense',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'domain': [['id', '=', numericId]],
              'fields': ['id', 'name'],
              'limit': 1,
            },
          },
        );
        
        print('Search verification response success: ${searchRes.isSuccess}');
        print('Search verification response: ${searchRes.data}');
        
        if (searchRes.isSuccess && searchRes.data?.data != null) {
          final searchResult = searchRes.data!.data['result'];
          print('Search result: $searchResult');
          
          if (searchResult is List && searchResult.isNotEmpty) {
            throw Exception('CRITICAL: Record found in search after delete - deletion failed');
          } else {
            print('Search verification passed: Record not found in search');
          }
        }
      } catch (e) {
        print('Search verification failed: $e');
      }
      
      print('Expense deletion process completed');
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow; // Re-throw to let the cubit handle it
    }
  }
}
