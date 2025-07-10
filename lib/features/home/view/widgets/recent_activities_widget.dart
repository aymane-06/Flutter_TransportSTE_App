import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/dashboard_model.dart';

class RecentActivitiesWidget extends StatelessWidget {
  final List<RecentActivityModel> activities;

  const RecentActivitiesWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activités récentes',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all activities
              },
              child: Text(
                'Voir tout',
                style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
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
          child: activities.isEmpty
              ? _EmptyActivities()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: AppColors.grey200, height: 1),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _ActivityItem(activity: activity);
                  },
                ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final RecentActivityModel activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Activity Icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: _getActivityColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              _getActivityIcon(),
              size: 20.sp,
              color: _getActivityColor(),
            ),
          ),

          SizedBox(width: 12.w),

          // Activity Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  activity.description,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Time
          Text(
            _formatTime(activity.createdAt),
            style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor() {
    switch (activity.type.toLowerCase()) {
      case 'order':
        return AppColors.primary;
      case 'payment':
        return Colors.green;
      case 'delivery':
        return Colors.orange;
      case 'user':
        return Colors.purple;
      default:
        return AppColors.grey600;
    }
  }

  IconData _getActivityIcon() {
    switch (activity.type.toLowerCase()) {
      case 'order':
        return Icons.shopping_cart_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'user':
        return Icons.person_outline;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

class _EmptyActivities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(Icons.timeline_outlined, size: 48.sp, color: AppColors.grey400),
          SizedBox(height: 16.h),
          Text(
            'Aucune activité récente',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Les activités apparaîtront ici',
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}
