import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pennywise/models/expense.dart';
import 'package:pennywise/models/bill.dart';
import 'package:pennywise/models/household_member.dart';

class LocalStorageService {
  Future<void> saveExpenses(String userId, List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'expenses_$userId';
    final jsonList = expenses.map((e) => e.toMap()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<Expense>> getExpenses(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'expenses_$userId';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((map) => Expense.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveBills(String userId, List<Bill> bills) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'bills_$userId';
    final jsonList = bills.map((b) => b.toMap()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<Bill>> getBills(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'bills_$userId';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((map) => Bill.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMembers(String userId, List<HouseholdMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'members_$userId';
    final jsonList = members.map((m) => m.toMap()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<HouseholdMember>> getMembers(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'members_$userId';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((map) => HouseholdMember.fromMap(map as Map<String, dynamic>))
        .toList();
  }
}
