import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(
          'Signaler un problème',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.report_problem_rounded,
                size: 80.sp,
                color: Colors.orange,
              ),
              SizedBox(height: 24.h),
              Text(
                'Signaler un problème',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Signalez rapidement tout problème technique, accident ou incident',
                style: TextStyle(fontSize: 16.sp, color: AppColors.grey600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.report_rounded),
        label: const Text('Nouveau rapport'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
