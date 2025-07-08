import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionsService {
  static const String _storageKey = 'transactions_list';

  /// Add a new transaction
  static Future<void> addTransaction(Transaction tx) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await getTransactions();
    transactions.add(tx);
    final encoded = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Get all transactions
  static Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    if (encoded == null) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((e) => Transaction.fromJson(e)).toList();
  }

  /// Clear all (for debugging)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}