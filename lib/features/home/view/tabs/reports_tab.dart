import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/report_model.dart';
import '../../view_model/reports_cubit/reports_cubit.dart';
import '../screens/create_report_screen.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  late final ReportsCubit _reportsCubit;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reportsCubit = getIt<ReportsCubit>();
    _reportsCubit.context = context;
    _reportsCubit.loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _reportsCubit,
      child: Scaffold(
        backgroundColor: AppColors.grey50,
        appBar: AppBar(
          title: Text(
            'Mes rapports',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _reportsCubit.refreshReports(),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: BlocBuilder<ReportsCubit, ReportsState>(
                builder: (context, state) {
                  if (state is ReportsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ReportsLoaded) {
                    return _buildReportsList(state.filteredReports);
                  } else if (state is ReportsError) {
                    return _buildErrorState(state.message);
                  }
                  return const Center(child: Text('Chargement...'));
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _navigateToCreateReport(),
            elevation: 0,
            backgroundColor: Colors.transparent,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Nouveau rapport',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un rapport...',
              hintStyle: TextStyle(color: AppColors.grey500),
              prefixIcon: Icon(Icons.search, color: AppColors.grey500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            onChanged: (value) {
              _reportsCubit.applyFilters(searchQuery: value);
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildTypeFilter()),
              SizedBox(width: 12.w),
              Expanded(child: _buildStateFilter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        ReportType? selectedType;
        if (state is ReportsLoaded) {
          selectedType = state.selectedType;
        }

        return DropdownButtonFormField<ReportType?>(
          value: selectedType,
          decoration: InputDecoration(
            labelText: 'Type',
            labelStyle: TextStyle(color: AppColors.grey600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Tous les types')),
            ...ReportType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.name));
            }),
          ],
          onChanged: (value) {
            _reportsCubit.applyFilters(reportType: value);
          },
        );
      },
    );
  }

  Widget _buildStateFilter() {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        ReportState? selectedState;
        if (state is ReportsLoaded) {
          selectedState = state.selectedState;
        }

        return DropdownButtonFormField<ReportState?>(
          value: selectedState,
          decoration: InputDecoration(
            labelText: 'État',
            labelStyle: TextStyle(color: AppColors.grey600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Tous les états')),
            ...ReportState.values.map((state) {
              return DropdownMenuItem(value: state, child: Text(state.name));
            }),
          ],
          onChanged: (value) {
            _reportsCubit.applyFilters(reportState: value);
          },
        );
      },
    );
  }

  Widget _buildReportsList(List<DriverReport> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 64.sp,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucun rapport trouvé',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.grey700,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Créez votre premier rapport de problème',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.grey500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _reportsCubit.refreshReports(),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(DriverReport report) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [Colors.white, AppColors.grey50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: () => _showReportDetails(report),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTypeIcon(report.reportType),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.subject,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            report.reportType.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grey600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStateChip(report.state),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  report.description,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.grey700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18.sp,
                      color: AppColors.grey500,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${report.reportDate.day.toString().padLeft(2, '0')}/${report.reportDate.month.toString().padLeft(2, '0')}/${report.reportDate.year}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Icon(
                      Icons.priority_high,
                      size: 18.sp,
                      color: _getPriorityColor(report.priority),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      report.priority.name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: _getPriorityColor(report.priority),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (report.location != null) ...[
                      SizedBox(width: 20.w),
                      Icon(
                        Icons.location_on,
                        size: 18.sp,
                        color: AppColors.grey500,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          report.location!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.grey600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(ReportType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ReportType.incident:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case ReportType.accident:
        icon = Icons.car_crash;
        color = Colors.red;
        break;
      case ReportType.maintenance:
        icon = Icons.build;
        color = Colors.blue;
        break;
      case ReportType.fuel:
        icon = Icons.local_gas_station;
        color = Colors.green;
        break;
      case ReportType.customer:
        icon = Icons.person;
        color = Colors.purple;
        break;
      case ReportType.route:
        icon = Icons.map;
        color = Colors.teal;
        break;
      case ReportType.security:
        icon = Icons.security;
        color = Colors.red;
        break;
      case ReportType.other:
        icon = Icons.more_horiz;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Icon(icon, size: 24.sp, color: color),
    );
  }

  Widget _buildStateChip(ReportState state) {
    Color color;
    switch (state) {
      case ReportState.draft:
        color = Colors.grey;
        break;
      case ReportState.submitted:
        color = Colors.blue;
        break;
      case ReportState.acknowledged:
        color = Colors.orange;
        break;
      case ReportState.inProgress:
        color = Colors.purple;
        break;
      case ReportState.resolved:
        color = Colors.green;
        break;
      case ReportState.closed:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Text(
        state.name,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Erreur',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => _reportsCubit.refreshReports(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateReportScreen()),
    ).then((result) {
      if (result == true) {
        _reportsCubit.refreshReports();
      }
    });
  }

  void _showReportDetails(DriverReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return _buildReportDetailsSheet(report, scrollController);
        },
      ),
    );
  }

  Widget _buildReportDetailsSheet(
    DriverReport report,
    ScrollController scrollController,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              _buildTypeIcon(report.reportType),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.subject,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _buildStateChip(report.state),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              report.priority,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            report.priority.name,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _getPriorityColor(report.priority),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                _buildDetailSection('Description', report.description),
                if (report.location != null)
                  _buildDetailSection('Localisation', report.location!),
                if (report.weatherConditions != null)
                  _buildDetailSection(
                    'Conditions météo',
                    report.weatherConditions!,
                  ),
                if (report.witnesses != null)
                  _buildDetailSection('Témoins', report.witnesses!),
                if (report.policeReport)
                  _buildDetailSection(
                    'Rapport de police',
                    report.policeReportNumber ?? 'Oui',
                  ),
                if (report.insuranceClaim)
                  _buildDetailSection(
                    'Demande d\'assurance',
                    report.insuranceClaimNumber ?? 'Oui',
                  ),
                _buildDetailSection(
                  'Date du rapport',
                  '${report.reportDate.day.toString().padLeft(2, '0')}/${report.reportDate.month.toString().padLeft(2, '0')}/${report.reportDate.year} à ${report.reportDate.hour.toString().padLeft(2, '0')}:${report.reportDate.minute.toString().padLeft(2, '0')}',
                ),
                if (report.acknowledgedDate != null)
                  _buildDetailSection(
                    'Date d\'accusé de réception',
                    '${report.acknowledgedDate!.day.toString().padLeft(2, '0')}/${report.acknowledgedDate!.month.toString().padLeft(2, '0')}/${report.acknowledgedDate!.year}',
                  ),
                if (report.resolvedDate != null)
                  _buildDetailSection(
                    'Date de résolution',
                    '${report.resolvedDate!.day.toString().padLeft(2, '0')}/${report.resolvedDate!.month.toString().padLeft(2, '0')}/${report.resolvedDate!.year}',
                  ),
                if (report.resolutionNotes != null)
                  _buildDetailSection(
                    'Notes de résolution',
                    report.resolutionNotes!,
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              if (report.state == ReportState.draft) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateReportScreen(existingReport: report),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _reportsCubit.refreshReports();
                        }
                      });
                    },
                    child: const Text('Modifier'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _reportsCubit.submitReport(report.id!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Soumettre'),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey700),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.low:
        return Colors.green;
      case ReportPriority.medium:
        return Colors.orange;
      case ReportPriority.high:
        return Colors.red;
      case ReportPriority.urgent:
        return Colors.purple;
    }
  }
}
