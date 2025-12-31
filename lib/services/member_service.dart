import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pennywise/models/household_member.dart';
import 'package:pennywise/services/local_storage_service.dart';

class MemberService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  String? _userId;

  String? get userId => _userId;
  set userId(String? value) {
    _userId = value;
    if (value != null) {
      loadMembers();
    }
  }

  List<HouseholdMember> _members = [];
  List<HouseholdMember> get members => _members;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadMembers() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Try to load from Firestore
      try {
        final snapshot = await _firestore
            .collection('household_members')
            .where('userId', isEqualTo: _userId)
            .get();

        _members = snapshot.docs
            .map(
                (doc) => HouseholdMember.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
      } catch (e) {
        debugPrint('Firestore error, loading from local: $e');
        _members = await _localStorage.getMembers(_userId!);
      }

      // Also sync local storage
      await _localStorage.saveMembers(_userId!, _members);
    } catch (e) {
      debugPrint('Error loading members: $e');
      _members = await _localStorage.getMembers(_userId ?? '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMember(HouseholdMember member) async {
    if (_userId == null) return;

    try {
      // Save to Firestore
      try {
        await _firestore.collection('household_members').add(member.toMap());
      } catch (e) {
        debugPrint('Firestore error, saving locally: $e');
      }

      // Save to local storage
      _members.add(member);
      await _localStorage.saveMembers(_userId!, _members);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding member: $e');
      _members.add(member);
      await _localStorage.saveMembers(_userId!, _members);
      notifyListeners();
    }
  }

  Future<void> updateMember(HouseholdMember member) async {
    if (_userId == null) return;

    try {
      // Update in Firestore
      try {
        await _firestore
            .collection('household_members')
            .doc(member.id)
            .update(member.toMap());
      } catch (e) {
        debugPrint('Firestore error, updating locally: $e');
      }

      // Update in local storage
      final index = _members.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _members[index] = member;
        await _localStorage.saveMembers(_userId!, _members);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating member: $e');
    }
  }

  Future<void> deleteMember(String memberId) async {
    if (_userId == null) return;

    try {
      // Delete from Firestore
      try {
        await _firestore.collection('household_members').doc(memberId).delete();
      } catch (e) {
        debugPrint('Firestore error, deleting locally: $e');
      }

      // Delete from local storage
      _members.removeWhere((m) => m.id == memberId);
      await _localStorage.saveMembers(_userId!, _members);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting member: $e');
    }
  }
}
