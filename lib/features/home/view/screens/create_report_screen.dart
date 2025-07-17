import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/report_model.dart';
import '../../view_model/reports_cubit/reports_cubit.dart';

class CreateReportScreen extends StatefulWidget {
  final DriverReport? existingReport;

  const CreateReportScreen({super.key, this.existingReport});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ReportsCubit _reportsCubit;

  // Form controllers
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _weatherController = TextEditingController();
  final _witnessesController = TextEditingController();
  final _policeReportController = TextEditingController();
  final _insuranceClaimController = TextEditingController();

  // Form state
  ReportType _selectedType = ReportType.incident;
  ReportPriority _selectedPriority = ReportPriority.medium;
  DateTime _selectedDate = DateTime(
    2024,
    7,
    16,
    10,
    0,
  ); // Use a fixed past date to avoid future date validation error
  bool _policeReport = false;
  bool _insuranceClaim = false;

  @override
  void initState() {
    super.initState();
    _reportsCubit = getIt<ReportsCubit>();
    _reportsCubit.context = context;

    // Initialize form with existing report data if editing
    if (widget.existingReport != null) {
      _initializeWithExistingReport(widget.existingReport!);
    }

    // Set default priority based on report type
    _updatePriorityBasedOnType();
  }

  void _initializeWithExistingReport(DriverReport report) {
    _subjectController.text = report.subject;
    _descriptionController.text = report.description;
    _locationController.text = report.location ?? '';
    _weatherController.text = report.weatherConditions ?? '';
    _witnessesController.text = report.witnesses ?? '';
    _policeReportController.text = report.policeReportNumber ?? '';
    _insuranceClaimController.text = report.insuranceClaimNumber ?? '';

    _selectedType = report.reportType;
    _selectedPriority = report.priority;
    _selectedDate = report.reportDate;
    _policeReport = report.policeReport;
    _insuranceClaim = report.insuranceClaim;
  }

  void _updatePriorityBasedOnType() {
    switch (_selectedType) {
      case ReportType.accident:
        _selectedPriority = ReportPriority.urgent;
        break;
      case ReportType.security:
        _selectedPriority = ReportPriority.high;
        break;
      case ReportType.incident:
      case ReportType.maintenance:
        _selectedPriority = ReportPriority.medium;
        break;
      default:
        _selectedPriority = ReportPriority.low;
        break;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _weatherController.dispose();
    _witnessesController.dispose();
    _policeReportController.dispose();
    _insuranceClaimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _reportsCubit,
      child: BlocListener<ReportsCubit, ReportsState>(
        listener: (context, state) {
          if (state is ReportCreated) {
            _reportsCubit.showMessage('Rapport créé avec succès');
            Navigator.pop(context, true);
          } else if (state is ReportUpdated) {
            _reportsCubit.showMessage('Rapport mis à jour avec succès');
            Navigator.pop(context, true);
          } else if (state is ReportCreationError) {
            _reportsCubit.showMessage(state.message, isError: true);
          } else if (state is ReportUpdateError) {
            _reportsCubit.showMessage(state.message, isError: true);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            title: Text(
              widget.existingReport != null
                  ? 'Modifier le rapport'
                  : 'Nouveau rapport',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                _buildBasicInfoSection(),
                SizedBox(height: 24.h),
                _buildDetailsSection(),
                SizedBox(height: 24.h),
                _buildLocationSection(),
                SizedBox(height: 24.h),
                _buildAdditionalInfoSection(),
                SizedBox(height: 24.h),
                _buildLegalSection(),
                SizedBox(height: 32.h),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 4,
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
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Informations de base',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _buildReportTypeDropdown(),
              SizedBox(height: 16.h),
              _buildPriorityDropdown(),
              SizedBox(height: 16.h),
              _buildDateSelector(),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Sujet*',
                  labelStyle: TextStyle(color: AppColors.grey600),
                  hintText: 'Résumé bref du problème',
                  hintStyle: TextStyle(color: AppColors.grey500),
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
                ),
                style: TextStyle(color: AppColors.grey800),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le sujet est requis';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      elevation: 4,
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
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Description détaillée',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description*',
                  labelStyle: TextStyle(color: AppColors.grey600),
                  hintText: 'Décrivez en détail ce qui s\'est passé',
                  hintStyle: TextStyle(color: AppColors.grey500),
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
                ),
                style: TextStyle(color: AppColors.grey800),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est requise';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Localisation',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Lieu de l\'incident',
                hintText: 'Où s\'est produit l\'incident?',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations supplémentaires',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _weatherController,
              decoration: InputDecoration(
                labelText: 'Conditions météorologiques',
                hintText: 'Décrivez les conditions météo',
                prefixIcon: const Icon(Icons.wb_sunny),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _witnessesController,
              decoration: InputDecoration(
                labelText: 'Témoins',
                hintText: 'Informations sur les témoins (si applicable)',
                prefixIcon: const Icon(Icons.people),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalSection() {
    return Card(
      elevation: 4,
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
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.gavel,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Aspects légaux',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _buildPoliceReportSection(),
              SizedBox(height: 20.h),
              _buildInsuranceClaimSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoliceReportSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _policeReport,
                onChanged: (value) {
                  setState(() {
                    _policeReport = value ?? false;
                    if (!_policeReport) {
                      _policeReportController.clear();
                    }
                  });
                },
                activeColor: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Rapport de police déposé',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800,
                  ),
                ),
              ),
              Icon(
                Icons.local_police,
                color: _policeReport ? AppColors.primary : AppColors.grey400,
                size: 20.sp,
              ),
            ],
          ),
          if (_policeReport) ...[
            SizedBox(height: 16.h),
            TextFormField(
              controller: _policeReportController,
              decoration: InputDecoration(
                labelText: 'Numéro de rapport de police',
                labelStyle: TextStyle(color: AppColors.grey600),
                hintText: 'Saisissez le numéro de référence',
                hintStyle: TextStyle(color: AppColors.grey500),
                prefixIcon: Icon(Icons.local_police, color: AppColors.grey500),
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
              ),
              style: TextStyle(color: AppColors.grey800),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsuranceClaimSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _insuranceClaim,
                onChanged: (value) {
                  setState(() {
                    _insuranceClaim = value ?? false;
                    if (!_insuranceClaim) {
                      _insuranceClaimController.clear();
                    }
                  });
                },
                activeColor: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Demande d\'assurance',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800,
                  ),
                ),
              ),
              Icon(
                Icons.security,
                color: _insuranceClaim ? AppColors.primary : AppColors.grey400,
                size: 20.sp,
              ),
            ],
          ),
          if (_insuranceClaim) ...[
            SizedBox(height: 16.h),
            TextFormField(
              controller: _insuranceClaimController,
              decoration: InputDecoration(
                labelText: 'Numéro de demande d\'assurance',
                labelStyle: TextStyle(color: AppColors.grey600),
                hintText: 'Saisissez le numéro de référence',
                hintStyle: TextStyle(color: AppColors.grey500),
                prefixIcon: Icon(Icons.security, color: AppColors.grey500),
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
              ),
              style: TextStyle(color: AppColors.grey800),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportTypeDropdown() {
    return DropdownButtonFormField<ReportType>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Type de rapport*',
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
        prefixIcon: Icon(Icons.category, color: AppColors.grey500),
      ),
      items: ReportType.values.map((type) {
        return DropdownMenuItem(value: type, child: Text(type.name));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
            _updatePriorityBasedOnType();
          });
        }
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<ReportPriority>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'Priorité*',
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
        prefixIcon: Icon(Icons.priority_high, color: AppColors.grey500),
      ),
      items: ReportPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 12.sp,
                color: _getPriorityColor(priority),
              ),
              SizedBox(width: 8.w),
              Text(priority.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2024, 1, 1), // Start from 2024
          lastDate: DateTime(
            2024,
            12,
            31,
          ), // End at 2024 to avoid future date validation
        );
        if (date != null && mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_selectedDate),
          );
          if (time != null && mounted) {
            setState(() {
              _selectedDate = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date et heure de l\'incident*',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year} à ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16.sp, color: AppColors.grey800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        final isLoading = state is ReportCreating || state is ReportUpdating;

        return Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoading
                  ? [AppColors.grey400, AppColors.grey300]
                  : [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: (isLoading ? AppColors.grey400 : AppColors.primary)
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.existingReport != null
                        ? 'Mettre à jour le rapport'
                        : 'Créer le rapport',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _submitReport() {
    if (_formKey.currentState?.validate() ?? false) {
      final report = DriverReport(
        id: widget.existingReport?.id,
        reportDate: _selectedDate,
        driverId:
            widget.existingReport?.driverId ??
            '0', // Temporary value, will be set by repository
        reportType: _selectedType,
        priority: _selectedPriority,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        location: (_locationController.text.trim().isEmpty)
            ? null
            : _locationController.text.trim(),
        weatherConditions: (_weatherController.text.trim().isEmpty)
            ? null
            : _weatherController.text.trim(),
        witnesses: (_witnessesController.text.trim().isEmpty)
            ? null
            : _witnessesController.text.trim(),
        policeReport: _policeReport,
        policeReportNumber:
            _policeReport && (_policeReportController.text.trim().isNotEmpty)
            ? _policeReportController.text.trim()
            : null,
        insuranceClaim: _insuranceClaim,
        insuranceClaimNumber:
            _insuranceClaim &&
                (_insuranceClaimController.text.trim().isNotEmpty)
            ? _insuranceClaimController.text.trim()
            : null,
      );

      if (widget.existingReport != null) {
        _reportsCubit.updateReport(report);
      } else {
        _reportsCubit.createReport(report);
      }
    }
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
