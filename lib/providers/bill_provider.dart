import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pennywise/models/bill.dart';
import 'package:pennywise/services/local_storage_service.dart';
import 'package:pennywise/providers/auth_provider.dart';

final billServiceProvider = Provider((ref) => BillService(ref));

class BillService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();

  BillService(this._ref);

  String? get userId {
    final authState = _ref.watch(authStateProvider);
    return authState.value?.uid;
  }

  Future<List<Bill>> loadBills() async {
    final uid = userId;
    if (uid == null) return [];

    try {
      try {
        final snapshot = await _firestore
            .collection('bills')
            .where('userId', isEqualTo: uid)
            .get();

        final bills = snapshot.docs
            .map((doc) => Bill.fromMap({...doc.data(), 'id': doc.id}))
            .toList();

        await _localStorage.saveBills(uid, bills);
        return bills;
      } catch (e) {
        return await _localStorage.getBills(uid);
      }
    } catch (e) {
      return await _localStorage.getBills(uid);
    }
  }

  Future<void> addBill(Bill bill) async {
    final uid = userId;
    if (uid == null) return;

    try {
      try {
        await _firestore.collection('bills').add(bill.toMap());
      } catch (e) {
        // Continue with local save
      }

      final bills = await loadBills();
      bills.add(bill);
      await _localStorage.saveBills(uid, bills);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateBill(Bill bill) async {
    final uid = userId;
    if (uid == null) return;

    try {
      try {
        await _firestore.collection('bills').doc(bill.id).update(bill.toMap());
      } catch (e) {
        // Continue with local update
      }

      final bills = await loadBills();
      final index = bills.indexWhere((b) => b.id == bill.id);
      if (index != -1) {
        bills[index] = bill;
        await _localStorage.saveBills(uid, bills);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteBill(String billId) async {
    final uid = userId;
    if (uid == null) return;

    try {
      try {
        await _firestore.collection('bills').doc(billId).delete();
      } catch (e) {
        // Continue with local delete
      }

      final bills = await loadBills();
      bills.removeWhere((b) => b.id == billId);
      await _localStorage.saveBills(uid, bills);
    } catch (e) {
      // Handle error
    }
  }

  List<Bill> getUpcomingBills(List<Bill> bills) {
    final now = DateTime.now();
    final currentDay = now.day;
    return bills.where((bill) {
      if (!bill.isActive) return false;
      return bill.dayOfMonth >= currentDay;
    }).toList()
      ..sort((a, b) => a.dayOfMonth.compareTo(b.dayOfMonth));
  }
}

final billsProvider = FutureProvider<List<Bill>>((ref) async {
  final service = ref.watch(billServiceProvider);
  return await service.loadBills();
});
