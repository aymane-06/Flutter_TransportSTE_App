import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/expense_model.dart';
import '../../models/trip_model.dart';
import '../../view_model/expenses_cubit/expenses_cubit.dart';
import '../../view_model/trips_cubit/trips_cubit.dart';
import '../widgets/expense_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_chip_widget.dart';
import '../screens/expense_form_screen.dart';

class ExpensesTab extends StatefulWidget {
  const ExpensesTab({super.key});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  final TextEditingController _searchController = TextEditingController();
  late final ExpensesCubit _expensesCubit;
  late final TripsCubit _tripsCubit;
  List<Trip> _availableTrips = [];

  @override
  void initState() {
    super.initState();
    _expensesCubit = getIt<ExpensesCubit>();
    _tripsCubit = getIt<TripsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _expensesCubit.loadExpenses();
      _tripsCubit.loadTrips();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _expensesCubit.context = context;
        return _expensesCubit;
      },
      child: BlocBuilder<ExpensesCubit, ExpensesState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.grey50,
            appBar: AppBar(
              title: Text(
                'Dépenses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: () {
                    _showFilterBottomSheet();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Ajouter une dépense',
                  onPressed: () {
                    _showAddExpenseForm(context);
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Search and Filter Section
                _buildSearchAndFilterSection(state),

                // Statistics Row
                _buildStatisticsRow(state),

                // Expenses List
                Expanded(child: _buildExpensesList(state)),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showAddExpenseForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter dépense'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpensesList(ExpensesState state) {
    if (state is ExpensesLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ExpensesError) {
      return Center(
        child: EmptyStateWidget(
          title: 'Erreur',
          message: state.message,
          icon: Icons.error_outline_rounded,
          onActionPressed: () => _expensesCubit.refreshExpenses(),
          actionLabel: 'Réessayer',
        ),
      );
    } else if (state is ExpensesLoaded) {
      if (state.filteredExpenses.isEmpty) {
        return EmptyStateWidget(
          title: 'Aucune dépense trouvée',
          message:
              'Essayez de modifier vos filtres pour voir les dépenses disponibles',
          icon: Icons.receipt_long_rounded,
          onActionPressed: () => _expensesCubit.refreshExpenses(),
          actionLabel: 'Actualiser',
        );
      } else {
        return RefreshIndicator(
          onRefresh: () => _expensesCubit.refreshExpenses(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            itemCount: state.filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = state.filteredExpenses[index];
              return ExpenseCard(
                expense: expense,
                onTap: () => _showExpenseDetails(expense),
                onEdit: () => _showEditExpenseDialog(expense),
                onDelete: () => _showDeleteConfirmation(expense),
              );
            },
          ),
        );
      }
    }

    // Default empty widget for initial state
    return const SizedBox.shrink();
  }

  Widget _buildSearchAndFilterSection(ExpensesState state) {
    String currentQuery = '';
    ExpenseType? currentExpenseType;

    if (state is ExpensesLoaded) {
      currentQuery = state.searchQuery;
      currentExpenseType = state.selectedExpenseType;

      // Update search controller text if needed
      if (_searchController.text != currentQuery) {
        _searchController.text = currentQuery;
      }
    }

    return Container(
      color: AppColors.primary,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey300.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _expensesCubit.applyFilters(searchQuery: value);
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher une dépense...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: currentQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _expensesCubit.applyFilters(searchQuery: '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Expense Type Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    [
                      {'value': null, 'label': 'Tous'},
                      {'value': ExpenseType.fuel, 'label': 'Carburant'},
                      {'value': ExpenseType.toll, 'label': 'Péages'},
                      {'value': ExpenseType.meals, 'label': 'Repas'},
                      {
                        'value': ExpenseType.accommodation,
                        'label': 'Hébergement',
                      },
                      {
                        'value': ExpenseType.maintenance,
                        'label': 'Maintenance',
                      },
                      {'value': ExpenseType.other, 'label': 'Autre'},
                    ].map((typeMap) {
                      final value = typeMap['value'] as ExpenseType?;
                      final label = typeMap['label'] as String;
                      final isSelected = currentExpenseType == value;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: FilterChipWidget(
                          label: label,
                          isSelected: isSelected,
                          onSelected: (selected) {
                            _expensesCubit.applyFilters(expenseType: value);
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow(ExpensesState state) {
    // Default values
    String totalExpenses = '0';
    String totalAmount = '0.00';
    String thisMonth = '0.00';

    if (state is ExpensesLoaded) {
      totalExpenses = state.filteredExpenses.length.toString();
      totalAmount = state.filteredExpenses
          .fold(0.0, (sum, expense) => sum + expense.amount)
          .toStringAsFixed(2);

      final now = DateTime.now();
      final thisMonthExpenses = state.filteredExpenses.where(
        (expense) =>
            expense.date.month == now.month && expense.date.year == now.year,
      );
      thisMonth = thisMonthExpenses
          .fold(0.0, (sum, expense) => sum + expense.amount)
          .toStringAsFixed(2);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total dépenses',
              value: totalExpenses,
              icon: Icons.receipt_long_rounded,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              title: 'Montant total',
              value: '$totalAmount MAD',
              icon: Icons.monetization_on_rounded,
              color: Colors.green,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              title: 'Ce mois',
              value: '$thisMonth MAD',
              icon: Icons.calendar_month_rounded,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtres avancés',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.h),
            const Text('Fonctionnalité en cours de développement'),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDetails(TripExpense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${_getExpenseTypeName(expense.expenseType)}'),
            Text('Montant: ${expense.amount.toStringAsFixed(2)} MAD'),
            Text('Date: ${expense.date.toString().split(' ')[0]}'),
            if (expense.location != null) Text('Lieu: ${expense.location}'),
            if (expense.supplier != null)
              Text('Fournisseur: ${expense.supplier}'),
            if (expense.receiptNumber != null)
              Text('Numéro de reçu: ${expense.receiptNumber}'),
            if (expense.notes != null) Text('Notes: ${expense.notes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseForm(BuildContext context) {
    // Get available trips for the expense form
    _tripsCubit.loadTrips().then((_) {
      final tripsState = _tripsCubit.state;

      if (tripsState is TripsLoaded) {
        _availableTrips = tripsState.allTrips;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseFormScreen(
              availableTrips: _availableTrips,
              onSave: (expense) {
                _expensesCubit.addExpense(expense);
              },
            ),
          ),
        );
      }
    });
  }

  void _showEditExpenseDialog(TripExpense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(
          expense: expense,
          onSave: (updatedExpense) {
            _expensesCubit.updateExpense(updatedExpense);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(TripExpense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${expense.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('Delete button pressed for expense: ${expense.id} - ${expense.name}');
              if (expense.id != null && expense.id!.isNotEmpty) {
                print('Calling deleteExpense with ID: ${expense.id}');
                _expensesCubit.deleteExpense(expense.id!);
              } else {
                print('Error: Expense ID is null or empty');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur: ID de dépense invalide'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
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
