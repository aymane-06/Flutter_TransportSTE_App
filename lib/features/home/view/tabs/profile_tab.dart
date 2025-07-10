import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/repository/auth_repo.dart';
import '../../view_model/home_cubit/home_cubit.dart';
import '../widgets/user_profile_header.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            title: Text(
              'Mon Profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.primary,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await _handleLogout(context);
                  }
                },
                itemBuilder: (context) => [
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
          body: state is HomeLoaded
              ? SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      UserProfileHeader(user: state.user),
                      SizedBox(height: 24.h),
                      // Additional profile content can be added here
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey300.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Paramètres du profil',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey800,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Cette section sera bientôt disponible pour modifier vos informations personnelles.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.grey600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
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
