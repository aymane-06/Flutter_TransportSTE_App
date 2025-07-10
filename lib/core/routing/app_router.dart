import 'package:flutter/material.dart';
import '../../features/auth/view/screens/server_config_screen.dart';
import '../../features/auth/view/screens/splash_page.dart';
import '../../features/auth/view/screens/signin_screen.dart';
import '../../features/home/view/screens/home_screen.dart';
import '../../features/profile/view/screens/profile_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String signin = '/signin';
  static const String login = '/login';
  static const String home = '/home';
  static const String serverConfig = '/server_config';
  static const String profile = '/profile';
  static const String appSettings = '/settings';

  // Trip routes
  static const String trips = '/trips';
  static const String addTrip = '/add_trip';
  static const String editTrip = '/edit_trip';
  static const String tripDetails = '/trip_details';

  // Vehicle routes
  static const String vehicles = '/vehicles';
  static const String addVehicle = '/add_vehicle';
  static const String editVehicle = '/edit_vehicle';
  static const String vehicleDetails = '/vehicle_details';

  // Driver routes
  static const String drivers = '/drivers';
  static const String addDriver = '/add_driver';
  static const String editDriver = '/edit_driver';
  static const String driverDetails = '/driver_details';

  // Report routes
  static const String reports = '/reports';
  static const String maintenance = '/maintenance';
  static const String addMaintenance = '/add_maintenance';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case serverConfig:
        return MaterialPageRoute(
          builder: (_) => const ServerConfigScreen(),
          settings: settings,
        );
      case signin:
      case login:
        return MaterialPageRoute(
          builder: (_) => const SignInScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      case appSettings:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Settings Page - Coming Soon')),
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
          settings: settings,
        );
    }
  }
}
