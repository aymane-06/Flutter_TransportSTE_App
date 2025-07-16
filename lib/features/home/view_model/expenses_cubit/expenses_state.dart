part of 'expenses_cubit.dart';

abstract class ExpensesState {}

class ExpensesInitial extends ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<TripExpense> allExpenses;
  final List<TripExpense> filteredExpenses;
  final String selectedTripId;
  final String searchQuery;
  final ExpenseType? selectedExpenseType;

  ExpensesLoaded({
    required this.allExpenses,
    required this.filteredExpenses,
    required this.selectedTripId,
    required this.searchQuery,
    this.selectedExpenseType,
  });
}

class ExpensesError extends ExpensesState {
  final String message;

  ExpensesError(this.message);
}
