import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pennywise/models/expense.dart';
import 'package:pennywise/services/local_storage_service.dart';

class ExpenseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  String? _userId;

  String? get userId => _userId;
  set userId(String? value) {
    _userId = value;
    if (value != null) {
      loadExpenses();
    }
  }

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadExpenses() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Try to load from Firestore
      try {
        final snapshot = await _firestore
            .collection('expenses')
            .where('userId', isEqualTo: _userId)
            .orderBy('date', descending: true)
            .get();

        _expenses = snapshot.docs
            .map((doc) => Expense.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
      } catch (e) {
        // If Firestore fails, load from local storage
        debugPrint('Firestore error, loading from local: $e');
        _expenses = await _localStorage.getExpenses(_userId!);
      }

      // Also sync local storage
      await _localStorage.saveExpenses(_userId!, _expenses);
    } catch (e) {
      debugPrint('Error loading expenses: $e');
      // Fallback to local storage
      _expenses = await _localStorage.getExpenses(_userId ?? '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    if (_userId == null) return;

    try {
      // Save to Firestore
      try {
        await _firestore.collection('expenses').add(expense.toMap());
      } catch (e) {
        debugPrint('Firestore error, saving locally: $e');
      }

      // Save to local storage
      _expenses.insert(0, expense);
      await _localStorage.saveExpenses(_userId!, _expenses);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding expense: $e');
      // Still save locally
      _expenses.insert(0, expense);
      await _localStorage.saveExpenses(_userId!, _expenses);
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    if (_userId == null) return;

    try {
      // Update in Firestore
      try {
        await _firestore
            .collection('expenses')
            .doc(expense.id)
            .update(expense.toMap());
      } catch (e) {
        debugPrint('Firestore error, updating locally: $e');
      }

      // Update in local storage
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        await _localStorage.saveExpenses(_userId!, _expenses);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating expense: $e');
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    if (_userId == null) return;

    try {
      // Delete from Firestore
      try {
        await _firestore.collection('expenses').doc(expenseId).delete();
      } catch (e) {
        debugPrint('Firestore error, deleting locally: $e');
      }

      // Delete from local storage
      _expenses.removeWhere((e) => e.id == expenseId);
      await _localStorage.saveExpenses(_userId!, _expenses);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
    }
  }

  List<Expense> getExpensesByMonth(DateTime month) {
    return _expenses.where((expense) {
      return expense.date.year == month.year &&
          expense.date.month == month.month;
    }).toList();
  }

  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  List<Expense> getExpensesByMember(String? memberId) {
    if (memberId == null) return [];
    return _expenses.where((expense) => expense.memberId == memberId).toList();
  }

  double getTotalByMonth(DateTime month) {
    return getExpensesByMonth(month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getCategoryTotalsByMonth(DateTime month) {
    final monthExpenses = getExpensesByMonth(month);
    final Map<String, double> totals = {};
    for (var expense in monthExpenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }
    return totals;
  }
}
