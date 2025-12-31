import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pennywise/models/bill.dart';
import 'package:pennywise/services/local_storage_service.dart';

class BillService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  String? _userId;

  String? get userId => _userId;
  set userId(String? value) {
    _userId = value;
    if (value != null) {
      loadBills();
    }
  }

  List<Bill> _bills = [];
  List<Bill> get bills => _bills;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadBills() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Try to load from Firestore
      try {
        final snapshot = await _firestore
            .collection('bills')
            .where('userId', isEqualTo: _userId)
            .get();

        _bills = snapshot.docs
            .map((doc) => Bill.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
      } catch (e) {
        debugPrint('Firestore error, loading from local: $e');
        _bills = await _localStorage.getBills(_userId!);
      }

      // Also sync local storage
      await _localStorage.saveBills(_userId!, _bills);
    } catch (e) {
      debugPrint('Error loading bills: $e');
      _bills = await _localStorage.getBills(_userId ?? '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBill(Bill bill) async {
    if (_userId == null) return;

    try {
      // Save to Firestore
      try {
        await _firestore.collection('bills').add(bill.toMap());
      } catch (e) {
        debugPrint('Firestore error, saving locally: $e');
      }

      // Save to local storage
      _bills.add(bill);
      await _localStorage.saveBills(_userId!, _bills);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding bill: $e');
      _bills.add(bill);
      await _localStorage.saveBills(_userId!, _bills);
      notifyListeners();
    }
  }

  Future<void> updateBill(Bill bill) async {
    if (_userId == null) return;

    try {
      // Update in Firestore
      try {
        await _firestore.collection('bills').doc(bill.id).update(bill.toMap());
      } catch (e) {
        debugPrint('Firestore error, updating locally: $e');
      }

      // Update in local storage
      final index = _bills.indexWhere((b) => b.id == bill.id);
      if (index != -1) {
        _bills[index] = bill;
        await _localStorage.saveBills(_userId!, _bills);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating bill: $e');
    }
  }

  Future<void> deleteBill(String billId) async {
    if (_userId == null) return;

    try {
      // Delete from Firestore
      try {
        await _firestore.collection('bills').doc(billId).delete();
      } catch (e) {
        debugPrint('Firestore error, deleting locally: $e');
      }

      // Delete from local storage
      _bills.removeWhere((b) => b.id == billId);
      await _localStorage.saveBills(_userId!, _bills);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting bill: $e');
    }
  }

  List<Bill> getUpcomingBills() {
    final now = DateTime.now();
    final currentDay = now.day;
    return _bills.where((bill) {
      if (!bill.isActive) return false;
      return bill.dayOfMonth >= currentDay;
    }).toList()
      ..sort((a, b) => a.dayOfMonth.compareTo(b.dayOfMonth));
  }
}
