import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/repository/auth_repo.dart';
import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/routing/app_router.dart';
import '../../view_model/home_cubit/home_cubit.dart';
import '../../models/dashboard_model.dart';
import '../widgets/driver_stat_card.dart';
import '../widgets/recent_activities_widget.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/driver_welcome_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            title: Text(
              'Tableau de bord',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  switch (value) {
                    case 'profile':
                      Navigator.pushNamed(context, AppRouter.profile);
                      break;
                    case 'settings':
                      Navigator.pushNamed(context, AppRouter.appSettings);
                      break;
                    case 'logout':
                      await _handleLogout(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline),
                        SizedBox(width: 8.w),
                        const Text('Profil'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined),
                        SizedBox(width: 8.w),
                        const Text('Paramètres'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8.w),
                        const Text(
                          'Déconnexion',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: _buildDashboardContent(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state is HomeError) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  context.read<HomeCubit>().refreshData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is HomeLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Welcome Card
          DriverWelcomeCard(user: state.user),

          SizedBox(height: 24.h),

          // Driver Stats
          _buildDriverStats(state.dashboardStats),

          SizedBox(height: 24.h),

          // Quick Actions
          const QuickActionsWidget(),

          SizedBox(height: 24.h),

          // Recent Activities
          RecentActivitiesWidget(
            activities: state.dashboardStats.recentActivities,
          ),

          SizedBox(height: 24.h),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDriverStats(DashboardStatsModel dashboardStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques du chauffeur',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey800,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: DriverStatCard(
                title: 'Voyages Totals',
                value: dashboardStats.totalTrips.toString(),
                icon: Icons.route_rounded,
                color: AppColors.primary,
                trend: '+${dashboardStats.ongoingTrips}',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: DriverStatCard(
                title: 'Terminés',
                value: dashboardStats.completedTrips.toString(),
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                trend: '+${dashboardStats.completedTrips}',
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: DriverStatCard(
                title: 'En Cours',
                value: dashboardStats.ongoingTrips.toString(),
                icon: Icons.pending_rounded,
                color: AppColors.warning,
                trend: '${dashboardStats.ongoingTrips}',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: DriverStatCard(
                title: 'Dépenses',
                value: '€${dashboardStats.totalExpenses.toStringAsFixed(0)}',
                icon: Icons.euro_rounded,
                color: AppColors.secondary,
                trend:
                    '+€${(dashboardStats.totalExpenses * 0.1).toStringAsFixed(0)}',
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

Future<void> _handleLogout(BuildContext context) async {
  final authRepo = getIt<AuthRepo>();
  await authRepo.logout();
  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.signin,
      (route) => false,
    );
  }
}
