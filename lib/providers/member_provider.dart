import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pennywise/models/household_member.dart';
import 'package:pennywise/services/local_storage_service.dart';
import 'package:pennywise/providers/auth_provider.dart';

final memberServiceProvider = Provider((ref) => MemberService(ref));

class MemberService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();

  MemberService(this._ref);

  String? get userId {
    final authState = _ref.watch(authStateProvider);
    return authState.value?.uid;
  }

  Future<List<HouseholdMember>> loadMembers() async {
    final uid = userId;
    if (uid == null) return [];

    try {
      try {
        final snapshot = await _firestore
            .collection('household_members')
            .where('userId', isEqualTo: uid)
            .get();

        final members = snapshot.docs
            .map(
                (doc) => HouseholdMember.fromMap({...doc.data(), 'id': doc.id}))
            .toList();

        await _localStorage.saveMembers(uid, members);
        return members;
      } catch (e) {
        return await _localStorage.getMembers(uid);
      }
    } catch (e) {
      return await _localStorage.getMembers(uid);
    }
  }

  Future<void> addMember(HouseholdMember member) async {
    final uid = userId;
    if (uid == null) return;

    try {
      try {
        await _firestore.collection('household_members').add(member.toMap());
      } catch (e) {
        // Continue with local save
      }

      final members = await loadMembers();
      members.add(member);
      await _localStorage.saveMembers(uid, members);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateMember(HouseholdMember member) async {
    final uid = userId;
    if (uid == null) return;

    try {
      try {
        await _firestore
            .collection('household_members')
            .doc(member.id)
            .update(member.toMap());
      } catch (e) {
        // Continue with local update
      }

      final members = await loadMembers();
      final index = members.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        members[index] = member;
        await _localStorage.saveMembers(uid, members);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteMember(String memberId) async {
    final uid = userId;
    if (uid == null) return;

    try {
      try {
        await _firestore.collection('household_members').doc(memberId).delete();
      } catch (e) {
        // Continue with local delete
      }

      final members = await loadMembers();
      members.removeWhere((m) => m.id == memberId);
      await _localStorage.saveMembers(uid, members);
    } catch (e) {
      // Handle error
    }
  }
}

final membersProvider = FutureProvider<List<HouseholdMember>>((ref) async {
  final service = ref.watch(memberServiceProvider);
  return await service.loadMembers();
});
