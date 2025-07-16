import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../features/auth/repository/api_config_repo.dart';
import '../../features/auth/repository/auth_repo.dart';
import '../../features/auth/view_model/login/login_cubit.dart';
import '../../features/auth/view_model/api_config_cubit/api_config_cubit.dart';
import '../../features/home/repository/home_repo.dart';
import '../../features/home/view_model/home_cubit/home_cubit.dart';
import '../../features/home/view_model/trips_cubit/trips_cubit.dart';
import '../../features/home/view_model/expenses_cubit/expenses_cubit.dart';
import '../services/api_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Dio
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Services
  getIt.registerLazySingleton<ApiService>(
    () => ApiServiceImp(getIt<Dio>(), getIt<SharedPreferences>()),
  );

  // Repositories
  getIt.registerLazySingleton<ApiConfigRepo>(
    () => ApiConfigRepoImp(
      preferences: getIt<SharedPreferences>(),
      apiService: getIt<ApiService>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImp(
      apiService: getIt<ApiService>(),
      preferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<HomeRepo>(
    () => HomeRepoImp(
      apiService: getIt<ApiService>(),
      preferences: getIt<SharedPreferences>(),
    ),
  );

  // Cubits
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(authRepo: getIt<AuthRepo>()),
  );

  getIt.registerFactory<ApiConfigCubit>(
    () => ApiConfigCubit(repo: getIt<ApiConfigRepo>()),
  );

  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(homeRepo: getIt<HomeRepo>()),
  );

  getIt.registerFactory<TripsCubit>(
    () => TripsCubit(homeRepo: getIt<HomeRepo>()),
  );

  getIt.registerFactory<ExpensesCubit>(() => ExpensesCubit(getIt<HomeRepo>()));
}
