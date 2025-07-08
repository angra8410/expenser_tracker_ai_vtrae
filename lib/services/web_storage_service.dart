import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/transaction.dart';

/// Web-compatible storage service using SharedPreferences
class WebStorageService {
  static SharedPreferences? _prefs;
  
  // Storage keys
  static const String _categoriesKey = 'categories';
  static const String _transactionsKey = 'transactions';
  static const String _budgetsKey = 'budgets';
  static const String _firstRunKey = 'first_run';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('✅ Web storage initialized');
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('WebStorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Categories Management
  static Future<List<Category>> getCategories() async {
    final categoriesJson = _prefs?.getString(_categoriesKey);
    if (categoriesJson == null) return [];
    
    final List<dynamic> categoriesList = json.decode(categoriesJson);
    return categoriesList.map((json) => Category.fromJson(json)).toList();
  }

  static Future<void> saveCategories(List<Category> categories) async {
    final categoriesJson = json.encode(categories.map((c) => c.toJson()).toList());
    await _prefs?.setString(_categoriesKey, categoriesJson);
  }

  static Future<void> addCategory(Category category) async {
    final categories = await getCategories();
    categories.add(category);
    await saveCategories(categories);
  }

  // Transactions Management
  static Future<List<Transaction>> getTransactions() async {
    final transactionsJson = _prefs?.getString(_transactionsKey);
    if (transactionsJson == null) return [];
    
    final List<dynamic> transactionsList = json.decode(transactionsJson);
    return transactionsList.map((json) => Transaction.fromJson(json)).toList();
  }

  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final transactionsJson = json.encode(transactions.map((t) => t.toJson()).toList());
    await _prefs?.setString(_transactionsKey, transactionsJson);
  }
  static Future<void> addTransaction(Transaction transaction) async {
  try {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
    print('✅ Single transaction added: ${transaction.description}');
  } catch (e) {
    print('❌ Error adding single transaction: $e');
    throw e;
  }
}	


  static Future<void> addTransactions(List<Transaction> newTransactions) async {
    final transactions = await getTransactions();
    transactions.addAll(newTransactions);
    await saveTransactions(transactions);
  }

  // Budgets Management
  static Future<Map<String, double>> getBudgets() async {
    final budgetsJson = _prefs?.getString(_budgetsKey);
    if (budgetsJson == null) return {};
    
    final Map<String, dynamic> budgetsMap = json.decode(budgetsJson);
    return budgetsMap.map((key, value) => MapEntry(key, value.toDouble()));
  }

  static Future<void> saveBudgets(Map<String, double> budgets) async {
    final budgetsJson = json.encode(budgets);
    await _prefs?.setString(_budgetsKey, budgetsJson);
  }

  // App State Management
  static bool get isFirstRun {
    return _prefs?.getBool(_firstRunKey) ?? true;
  }

  static Future<void> markFirstRunComplete() async {
    await _prefs?.setBool(_firstRunKey, false);
  }

  // Data Management
  static Future<void> clearAllData() async {
    await _prefs?.remove(_categoriesKey);
    await _prefs?.remove(_transactionsKey);
    await _prefs?.remove(_budgetsKey);
    print('🧹 All data cleared');
  }

  static Future<Map<String, dynamic>> getStorageStats() async {
    final categories = await getCategories();
    final transactions = await getTransactions();
    final budgets = await getBudgets();
    
    return {
      'categories': categories.length,
      'transactions': transactions.length,
      'budgets': budgets.length,
      'isFirstRun': isFirstRun,
    };
  }
}