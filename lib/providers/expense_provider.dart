import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pennywise/models/expense.dart';
import 'package:pennywise/services/local_storage_service.dart';
import 'package:pennywise/providers/auth_provider.dart';

final expenseServiceProvider = Provider((ref) => ExpenseService(ref));

class ExpenseService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();

  ExpenseService(this._ref);

  String? get userId {
    final authState = _ref.watch(authStateProvider);
    return authState.value?.uid;
  }

  Future<List<Expense>> loadExpenses() async {
    final uid = userId;
    if (uid == null) return [];

    try {
      try {
        final snapshot = await _firestore
            .collection('expenses')
            .where('userId', isEqualTo: uid)
            .orderBy('date', descending: true)
            .get();

        final expenses = snapshot.docs
            .map((doc) => Expense.fromMap({...doc.data(), 'id': doc.id}))
            .toList();

        await _localStorage.saveExpenses(uid, expenses);
        return expenses;
      } catch (e) {
        return await _localStorage.getExpenses(uid);
      }
    } catch (e) {
      return await _localStorage.getExpenses(uid);
    }
  }

  Future<void> addExpense(Expense expense) async {
    final uid = userId;
    if (uid == null) return;

    try {
      try {
        await _firestore.collection('expenses').add(expense.toMap());
      } catch (e) {
        // Continue with local save
      }

      final expenses = await loadExpenses();
      expenses.insert(0, expense);
      await _localStorage.saveExpenses(uid, expenses);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateExpense(Expense expense) async {
    final uid = userId;
    if (uid == null) return;

    try {
      try {
        await _firestore
            .collection('expenses')
            .doc(expense.id)
            .update(expense.toMap());
      } catch (e) {
        // Continue with local update
      }

      final expenses = await loadExpenses();
      final index = expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        expenses[index] = expense;
        await _localStorage.saveExpenses(uid, expenses);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    final uid = userId;
    if (uid == null) return;

    try {
      try {
        await _firestore.collection('expenses').doc(expenseId).delete();
      } catch (e) {
        // Continue with local delete
      }

      final expenses = await loadExpenses();
      expenses.removeWhere((e) => e.id == expenseId);
      await _localStorage.saveExpenses(uid, expenses);
    } catch (e) {
      // Handle error
    }
  }

  List<Expense> getExpensesByMonth(List<Expense> expenses, DateTime month) {
    return expenses.where((expense) {
      return expense.date.year == month.year &&
          expense.date.month == month.month;
    }).toList();
  }

  double getTotalByMonth(List<Expense> expenses, DateTime month) {
    return getExpensesByMonth(expenses, month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getCategoryTotalsByMonth(
      List<Expense> expenses, DateTime month) {
    final monthExpenses = getExpensesByMonth(expenses, month);
    final Map<String, double> totals = {};
    for (var expense in monthExpenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }
    return totals;
  }
}

final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  return await service.loadExpenses();
});
