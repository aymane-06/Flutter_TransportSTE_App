import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../models/expense_model.dart';
import '../../repository/home_repo.dart';

part 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final HomeRepo _homeRepository;
  BuildContext? context;

  ExpensesCubit(this._homeRepository) : super(ExpensesInitial());

  Future<void> loadExpenses({
    String? tripId,
    String? searchQuery,
    ExpenseType? expenseType,
  }) async {
    emit(ExpensesLoading());
    try {
      final expenses = await _homeRepository.getExpenses(
        tripId: tripId,
        searchQuery: searchQuery,
        expenseType: expenseType,
      );

      emit(
        ExpensesLoaded(
          allExpenses: expenses,
          filteredExpenses: expenses,
          selectedTripId: tripId ?? 'all',
          searchQuery: searchQuery ?? '',
          selectedExpenseType: expenseType,
        ),
      );
    } catch (e) {
      emit(ExpensesError('Erreur lors du chargement des dépenses: $e'));
    }
  }

  void applyFilters({
    String? tripId,
    String? searchQuery,
    ExpenseType? expenseType,
  }) {
    if (state is ExpensesLoaded) {
      final currentState = state as ExpensesLoaded;

      final newTripId = tripId ?? currentState.selectedTripId;
      final newQuery = searchQuery ?? currentState.searchQuery;
      final newExpenseType = expenseType ?? currentState.selectedExpenseType;

      final filteredExpenses = _filterExpenses(
        currentState.allExpenses,
        newTripId,
        newQuery,
        newExpenseType,
      );

      emit(
        ExpensesLoaded(
          allExpenses: currentState.allExpenses,
          filteredExpenses: filteredExpenses,
          selectedTripId: newTripId,
          searchQuery: newQuery,
          selectedExpenseType: newExpenseType,
        ),
      );
    }
  }

  List<TripExpense> _filterExpenses(
    List<TripExpense> expenses,
    String? tripId,
    String? query,
    ExpenseType? expenseType,
  ) {
    return expenses.where((expense) {
      // Trip filter
      final matchesTrip =
          tripId == null || tripId == 'all' || expense.tripId == tripId;

      // Search query filter
      final matchesQuery =
          query == null ||
          query.isEmpty ||
          expense.name.toLowerCase().contains(query.toLowerCase()) ||
          (expense.supplier?.toLowerCase().contains(query.toLowerCase()) ??
              false) ||
          (expense.location?.toLowerCase().contains(query.toLowerCase()) ??
              false);

      // Expense type filter
      final matchesType =
          expenseType == null || expense.expenseType == expenseType;

      return matchesTrip && matchesQuery && matchesType;
    }).toList();
  }

  Future<void> refreshExpenses() async {
    if (state is ExpensesLoaded) {
      final currentState = state as ExpensesLoaded;
      await loadExpenses(
        tripId: currentState.selectedTripId == 'all'
            ? null
            : currentState.selectedTripId,
        searchQuery: currentState.searchQuery.isEmpty
            ? null
            : currentState.searchQuery,
        expenseType: currentState.selectedExpenseType,
      );
    } else {
      await loadExpenses();
    }
  }

  Future<void> addExpense(TripExpense expense) async {
    if (state is ExpensesLoaded) {
      try {
        print('Adding expense: ${expense.name}');
        await _homeRepository.createExpense(expense);
        await refreshExpenses();

        if (context != null) {
          ScaffoldMessenger.of(context!).showSnackBar(
            const SnackBar(
              content: Text('Dépense ajoutée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error in addExpense cubit: $e');
        if (context != null) {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'ajout: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Future<void> updateExpense(TripExpense expense) async {
    if (state is ExpensesLoaded) {
      try {
        print('Updating expense: ${expense.id} - ${expense.name}');
        await _homeRepository.updateExpense(expense);
        await refreshExpenses();

        if (context != null) {
          ScaffoldMessenger.of(context!).showSnackBar(
            const SnackBar(
              content: Text('Dépense mise à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error in updateExpense cubit: $e');
        if (context != null) {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à jour: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    if (state is ExpensesLoaded) {
      final currentState = state as ExpensesLoaded;
      
      try {
        print('ExpensesCubit: Starting delete process for ID: $expenseId');
        
        // Validate the expense ID
        if (expenseId.isEmpty) {
          throw Exception('ID de dépense vide');
        }
        
        // Find the expense to delete
        final expenseToDelete = currentState.filteredExpenses.firstWhere(
          (expense) => expense.id == expenseId,
          orElse: () => throw Exception('Dépense introuvable dans la liste'),
        );
        
        print('ExpensesCubit: Found expense to delete: ${expenseToDelete.name}');
        
        // Store the current count for verification
        final beforeCount = currentState.filteredExpenses.length;
        print('ExpensesCubit: Expenses count before deletion: $beforeCount');
        
        // Optimistically remove from UI first
        final updatedFiltered = currentState.filteredExpenses
            .where((expense) => expense.id != expenseId)
            .toList();
        final updatedAll = currentState.allExpenses
            .where((expense) => expense.id != expenseId)
            .toList();
        
        // Update UI immediately
        emit(ExpensesLoaded(
          allExpenses: updatedAll,
          filteredExpenses: updatedFiltered,
          selectedTripId: currentState.selectedTripId,
          searchQuery: currentState.searchQuery,
          selectedExpenseType: currentState.selectedExpenseType,
        ));
        
        print('ExpensesCubit: UI updated optimistically');
        
        // Show success message immediately
        if (context != null) {
          ScaffoldMessenger.of(context!).showSnackBar(
            const SnackBar(
              content: Text('Dépense supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Try to delete from server in background
        try {
          await _homeRepository.deleteExpense(expenseId);
          print('ExpensesCubit: Server deletion successful');
        } catch (apiError) {
          print('ExpensesCubit: Server deletion failed: $apiError');
          
          // If server deletion fails, revert the UI changes
          emit(ExpensesLoaded(
            allExpenses: currentState.allExpenses,
            filteredExpenses: currentState.filteredExpenses,
            selectedTripId: currentState.selectedTripId,
            searchQuery: currentState.searchQuery,
            selectedExpenseType: currentState.selectedExpenseType,
          ));
          
          if (context != null) {
            ScaffoldMessenger.of(context!).showSnackBar(
              SnackBar(
                content: Text('Erreur serveur: ${apiError.toString().replaceAll('Exception: ', '')}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
        
      } catch (e) {
        print('Error in deleteExpense cubit: $e');
        if (context != null) {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } else {
      print('ExpensesCubit: Cannot delete expense - state is not ExpensesLoaded');
      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          const SnackBar(
            content: Text('Impossible de supprimer - état invalide'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showExpenseCreationDenied() {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        const SnackBar(
          content: Text('Création de dépenses temporairement désactivée'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
