import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
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
              child: _QuickActionCard(
                title: 'Nouveau voyage',
                subtitle: 'Démarrer un voyage',
                icon: Icons.add_road_rounded,
                color: AppColors.primary,
                onTap: () {
                  // Navigate to new trip
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _QuickActionCard(
                title: 'Ajouter dépense',
                subtitle: 'Enregistrer une dépense',
                icon: Icons.receipt_long_rounded,
                color: Colors.green,
                onTap: () {
                  // Navigate to add expense
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Signaler problème',
                subtitle: 'Rapport d\'incident',
                icon: Icons.report_problem_rounded,
                color: Colors.orange,
                onTap: () {
                  // Navigate to report problem
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _QuickActionCard(
                title: 'Historique',
                subtitle: 'Voir l\'historique',
                icon: Icons.history_rounded,
                color: Colors.purple,
                onTap: () {
                  // Navigate to history
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 20.sp, color: color),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.grey400,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }
}
