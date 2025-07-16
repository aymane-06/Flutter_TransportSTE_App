import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/expense_model.dart';

class ExpenseCard extends StatelessWidget {
  final TripExpense expense;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _getExpenseTypeColor(
                        expense.expenseType,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getExpenseTypeIcon(expense.expenseType),
                      color: _getExpenseTypeColor(expense.expenseType),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _getExpenseTypeName(expense.expenseType),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${expense.amount.toStringAsFixed(2)} MAD',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(expense.date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Details Row
              if (expense.location != null || expense.supplier != null) ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    if (expense.location != null) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 16.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          expense.location!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (expense.supplier != null) ...[
                      if (expense.location != null) SizedBox(width: 16.w),
                      Icon(
                        Icons.business_outlined,
                        size: 16.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          expense.supplier!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Receipt Number
              if (expense.receiptNumber != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Reçu: ${expense.receiptNumber}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              // Action Buttons
              if (onEdit != null || onDelete != null) ...[
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null) ...[
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: Icon(Icons.edit_outlined, size: 16.sp),
                        label: const Text('Modifier'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                        ),
                      ),
                    ],
                    if (onDelete != null) ...[
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: Icon(Icons.delete_outline, size: 16.sp),
                        label: const Text('Supprimer'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getExpenseTypeColor(ExpenseType type) {
    switch (type) {
      case ExpenseType.fuel:
        return Colors.orange;
      case ExpenseType.toll:
        return Colors.blue;
      case ExpenseType.customs:
        return Colors.purple;
      case ExpenseType.accommodation:
        return Colors.green;
      case ExpenseType.meals:
        return Colors.red;
      case ExpenseType.maintenance:
        return Colors.amber;
      case ExpenseType.insurance:
        return Colors.indigo;
      case ExpenseType.parking:
        return Colors.cyan;
      case ExpenseType.driverAllowance:
        return Colors.teal;
      case ExpenseType.other:
        return Colors.grey;
    }
  }

  IconData _getExpenseTypeIcon(ExpenseType type) {
    switch (type) {
      case ExpenseType.fuel:
        return Icons.local_gas_station;
      case ExpenseType.toll:
        return Icons.toll;
      case ExpenseType.customs:
        return Icons.gavel;
      case ExpenseType.accommodation:
        return Icons.hotel;
      case ExpenseType.meals:
        return Icons.restaurant;
      case ExpenseType.maintenance:
        return Icons.build;
      case ExpenseType.insurance:
        return Icons.security;
      case ExpenseType.parking:
        return Icons.local_parking;
      case ExpenseType.driverAllowance:
        return Icons.person;
      case ExpenseType.other:
        return Icons.more_horiz;
    }
  }

  String _getExpenseTypeName(ExpenseType type) {
    switch (type) {
      case ExpenseType.fuel:
        return 'Carburant';
      case ExpenseType.toll:
        return 'Péages';
      case ExpenseType.customs:
        return 'Douane';
      case ExpenseType.accommodation:
        return 'Hébergement';
      case ExpenseType.meals:
        return 'Repas';
      case ExpenseType.maintenance:
        return 'Maintenance';
      case ExpenseType.insurance:
        return 'Assurance';
      case ExpenseType.parking:
        return 'Parking';
      case ExpenseType.driverAllowance:
        return 'Allocation chauffeur';
      case ExpenseType.other:
        return 'Autre';
    }
  }
}
