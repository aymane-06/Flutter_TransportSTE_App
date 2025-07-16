import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/expense_model.dart';
import '../../models/trip_model.dart';

class ExpenseFormScreen extends StatefulWidget {
  final TripExpense? expense;
  final List<Trip>? availableTrips;
  final Function(TripExpense) onSave;

  const ExpenseFormScreen({
    super.key,
    this.expense,
    this.availableTrips,
    required this.onSave,
  });

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _locationController = TextEditingController();
  final _supplierController = TextEditingController();
  final _receiptNumberController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedTripId;
  ExpenseType _selectedExpenseType = ExpenseType.fuel;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _initializeWithExistingExpense();
    } else {
      _initializeForNewExpense();
    }
  }

  void _initializeWithExistingExpense() {
    final expense = widget.expense!;
    _nameController.text = expense.name;
    _amountController.text = expense.amount.toString();
    _locationController.text = expense.location ?? '';
    _supplierController.text = expense.supplier ?? '';
    _receiptNumberController.text = expense.receiptNumber ?? '';
    _notesController.text = expense.notes ?? '';
    _selectedTripId = expense.tripId;
    _selectedExpenseType = expense.expenseType;
    _selectedDate = expense.date;
  }

  void _initializeForNewExpense() {
    _nameController.text = _getExpenseTypeName(_selectedExpenseType);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _locationController.dispose();
    _supplierController.dispose();
    _receiptNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense == null
              ? 'Ajouter une dépense'
              : 'Modifier la dépense',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Selection (only for new expenses)
              if (widget.expense == null && widget.availableTrips != null) ...[
                _buildSectionTitle('Voyage'),
                _buildTripDropdown(),
                SizedBox(height: 16.h),
              ],

              // Expense Type
              _buildSectionTitle('Type de dépense'),
              _buildExpenseTypeDropdown(),
              SizedBox(height: 16.h),

              // Name
              _buildSectionTitle('Description'),
              _buildTextFormField(
                controller: _nameController,
                label: 'Description de la dépense',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est requise';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Amount
              _buildSectionTitle('Montant'),
              _buildTextFormField(
                controller: _amountController,
                label: 'Montant (MAD)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le montant est requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un montant valide';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Le montant doit être supérieur à 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Date
              _buildSectionTitle('Date'),
              _buildDatePicker(),
              SizedBox(height: 16.h),

              // Location
              _buildSectionTitle('Lieu (optionnel)'),
              _buildTextFormField(
                controller: _locationController,
                label: 'Lieu de la dépense',
              ),
              SizedBox(height: 16.h),

              // Supplier
              _buildSectionTitle('Fournisseur (optionnel)'),
              _buildTextFormField(
                controller: _supplierController,
                label: 'Nom du fournisseur',
              ),
              SizedBox(height: 16.h),

              // Receipt Number
              _buildSectionTitle('Numéro de reçu (optionnel)'),
              _buildTextFormField(
                controller: _receiptNumberController,
                label: 'Numéro de reçu',
              ),
              SizedBox(height: 16.h),

              // Notes
              _buildSectionTitle('Notes (optionnel)'),
              _buildTextFormField(
                controller: _notesController,
                label: 'Notes supplémentaires',
                maxLines: 3,
              ),
              SizedBox(height: 32.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.expense == null ? 'Ajouter' : 'Modifier',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.grey800,
        ),
      ),
    );
  }

  Widget _buildTripDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedTripId,
        decoration: InputDecoration(
          hintText: 'Sélectionner un voyage',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        items: widget.availableTrips?.map((trip) {
          return DropdownMenuItem<String>(
            value: trip.id,
            child: Text(trip.name, style: TextStyle(fontSize: 14.sp)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedTripId = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez sélectionner un voyage';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildExpenseTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonFormField<ExpenseType>(
        value: _selectedExpenseType,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        items: ExpenseType.values.map((type) {
          return DropdownMenuItem<ExpenseType>(
            value: type,
            child: Text(
              _getExpenseTypeName(type),
              style: TextStyle(fontSize: 14.sp),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedExpenseType = value!;
            _nameController.text = _getExpenseTypeName(value);
          });
        },
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      validator: validator,
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.grey600),
            SizedBox(width: 12.w),
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: TextStyle(fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final expense = TripExpense(
        id: widget.expense?.id,
        tripId: _selectedTripId ?? widget.expense?.tripId ?? '',
        name: _nameController.text.trim(),
        expenseType: _selectedExpenseType,
        amount: double.parse(_amountController.text),
        currencyId: '1', // Default currency ID (instead of 'MAD')
        date: _selectedDate,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        supplier: _supplierController.text.trim().isEmpty
            ? null
            : _supplierController.text.trim(),
        receiptNumber: _receiptNumberController.text.trim().isEmpty
            ? null
            : _receiptNumberController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        companyId: '1', // Default company ID
      );

      print('Form saving expense: ${expense.toJson()}');
      widget.onSave(expense);
      Navigator.pop(context);
    } catch (e) {
      print('Error in form save: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
