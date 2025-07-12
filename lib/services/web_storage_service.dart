import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/recurring_transaction.dart';
import '../widgets/alert_center.dart';
import 'transactions_service.dart';

/// Web-compatible storage service using SharedPreferences with localStorage backup
class WebStorageService {
  static SharedPreferences? _prefs;
  static BuildContext? _context; // For showing alerts
  
  /// Set the context for showing alerts
  static void setContext(BuildContext context) {
    _context = context;
  }
  
  // Storage keys
  static const String _categoriesKey = 'categories';
  static const String _transactionsKey = 'transactions';
  static const String _budgetsKey = 'budgets';
  static const String _recurringTransactionsKey = 'recurring_transactions';
  static const String _firstRunKey = 'first_run';
  
  // Local storage backup keys (for web)
  static const String _localStorageTransactionsKey = 'expense_tracker_transactions';
  static const String _localStorageCategoriesKey = 'expense_tracker_categories';
  static const String _localStorageBudgetsKey = 'expense_tracker_budgets';
  static const String _localStorageRecurringTransactionsKey = 'expense_tracker_recurring_transactions';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Force reload SharedPreferences to ensure we have the latest data
    await _prefs!.reload();
    
    // Check if we need to restore from localStorage backup
    await _restoreFromLocalStorageIfNeeded();
    
    // Clean up any existing duplicate transactions
    await deduplicateTransactions();
    
    // Sync with TransactionsService to ensure data consistency
    await _syncWithTransactionsService();
    
    // Setup periodic backup to localStorage
    _setupPeriodicBackup();
    
    // Immediately backup all data to ensure it's saved
    await _backupAllDataToLocalStorage();
    
    print('✅ Web storage initialized and synced with TransactionsService');
  }

  // Generic storage methods
  static Future<String?> getValue(String key) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs!.getString(key);
  }

  static Future<void> setValue(String key, String value) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await _prefs!.setString(key, value);
    // Backup to localStorage
    html.window.localStorage[key] = value;
  }

  static dynamic jsonDecode(String value) {
    return json.decode(value);
  }

  static String jsonEncode(dynamic value) {
    return json.encode(value);
  }
  
  /// Setup periodic backup to localStorage every 30 seconds
  static void _setupPeriodicBackup() {
    try {
      // Use a periodic timer to backup data to localStorage
      Future.delayed(const Duration(seconds: 30), () async {
        await _backupAllDataToLocalStorage();
        _setupPeriodicBackup(); // Schedule next backup
      });
    } catch (e) {
      print('❌ Error setting up periodic backup: $e');
    }
  }
  
  /// Backup all data to localStorage
  static Future<void> _backupAllDataToLocalStorage() async {
    try {
      if (_prefs == null) return;
      
      bool anyDataBackedUp = false;
      
      // Backup transactions
      final transactionsJson = _prefs!.getString(_transactionsKey);
      if (transactionsJson != null) {
        html.window.localStorage[_localStorageTransactionsKey] = transactionsJson;
        anyDataBackedUp = true;
      }
      
      // Backup categories
      final categoriesJson = _prefs!.getString(_categoriesKey);
      if (categoriesJson != null) {
        html.window.localStorage[_localStorageCategoriesKey] = categoriesJson;
        anyDataBackedUp = true;
      }
      
      // Backup budgets
      final budgetsJson = _prefs!.getString(_budgetsKey);
      if (budgetsJson != null) {
        html.window.localStorage[_localStorageBudgetsKey] = budgetsJson;
        anyDataBackedUp = true;
      }
      
      // Backup recurring transactions
      final recurringTransactionsJson = _prefs!.getString(_recurringTransactionsKey);
      if (recurringTransactionsJson != null) {
        html.window.localStorage[_localStorageRecurringTransactionsKey] = recurringTransactionsJson;
        anyDataBackedUp = true;
      }
      
      print('✅ Periodic backup to localStorage completed');
      
      // Show alert if any data was backed up (but only occasionally to avoid too many alerts)
      if (anyDataBackedUp && _context != null && DateTime.now().second % 30 == 0) {
        AlertCenter.showSuccess(_context!, 'Your data has been backed up');
      }
    } catch (e) {
      print('❌ Error during periodic backup to localStorage: $e');
      if (_context != null) {
        AlertCenter.showError(_context!, 'Error backing up your data');
      }
    }
  }
  
  /// Restore data from localStorage if SharedPreferences is empty
  static Future<void> _restoreFromLocalStorageIfNeeded() async {
    try {
      if (_prefs == null) return;
      
      bool anyDataRestored = false;
      
      // Check and restore transactions
      if (!_prefs!.containsKey(_transactionsKey)) {
        final storedTransactions = html.window.localStorage[_localStorageTransactionsKey];
        if (storedTransactions != null) {
          await _prefs!.setString(_transactionsKey, storedTransactions);
          print('✅ Restored transactions from localStorage');
          anyDataRestored = true;
        }
      }
      
      // Check and restore categories
      if (!_prefs!.containsKey(_categoriesKey)) {
        final storedCategories = html.window.localStorage[_localStorageCategoriesKey];
        if (storedCategories != null) {
          await _prefs!.setString(_categoriesKey, storedCategories);
          print('✅ Restored categories from localStorage');
          anyDataRestored = true;
        }
      }
      
      // Check and restore budgets
      if (!_prefs!.containsKey(_budgetsKey)) {
        final storedBudgets = html.window.localStorage[_localStorageBudgetsKey];
        if (storedBudgets != null) {
          await _prefs!.setString(_budgetsKey, storedBudgets);
          print('✅ Restored budgets from localStorage');
          anyDataRestored = true;
        }
      }
      
      // Check and restore recurring transactions
      if (!_prefs!.containsKey(_recurringTransactionsKey)) {
        final storedRecurringTransactions = html.window.localStorage[_localStorageRecurringTransactionsKey];
        if (storedRecurringTransactions != null) {
          await _prefs!.setString(_recurringTransactionsKey, storedRecurringTransactions);
          print('✅ Restored recurring transactions from localStorage');
          anyDataRestored = true;
        }
      }
      
      // Show alert if any data was restored
      if (anyDataRestored && _context != null) {
        AlertCenter.showInfo(_context!, 'Your data has been restored from backup');
      }
    } catch (e) {
      print('❌ Error restoring from localStorage: $e');
      if (_context != null) {
        AlertCenter.showError(_context!, 'Error restoring data from backup');
      }
    }
  }
  
  // Sync data between WebStorageService and TransactionsService
  static Future<void> _syncWithTransactionsService() async {
    try {
      // Get transactions from both services (including test data for complete sync)
      final webTransactions = await getTransactions(includeTestData: true);
      final localTransactions = await TransactionsService.getTransactions(includeTestData: true);
      
      // Create a map to merge transactions, avoiding duplicates
      final Map<String, Transaction> transactionMap = {};
      
      // Add all transactions from both sources
      for (final tx in webTransactions) {
        transactionMap[tx.id] = tx;
      }
      
      for (final tx in localTransactions) {
        transactionMap[tx.id] = tx;
      }
      
      // Save the merged transactions (both services use same storage keys now)
      final mergedTransactions = transactionMap.values.toList();
      
      // Save to both services
      await saveTransactions(mergedTransactions);
      await TransactionsService.saveTransactions(mergedTransactions);
      
      print('✅ Synced ${mergedTransactions.length} transactions between services');
    } catch (e) {
      print('❌ Error syncing with TransactionsService: $e');
    }
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
    await setValue(_categoriesKey, categoriesJson);
  }

  // Transactions Management
  static Future<List<Transaction>> getTransactions({bool includeTestData = true}) async {
    final transactionsJson = _prefs?.getString(_transactionsKey);
    if (transactionsJson == null) return [];
    
    final List<dynamic> transactionsList = json.decode(transactionsJson);
    final transactions = transactionsList.map((json) => Transaction.fromJson(json)).toList();
    
    if (!includeTestData) {
      return transactions.where((tx) => !tx.id.startsWith('test')).toList();
    }
    return transactions;
  }

  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final transactionsJson = json.encode(transactions.map((t) => t.toJson()).toList());
    await setValue(_transactionsKey, transactionsJson);
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  static Future<void> updateTransaction(Transaction updatedTransaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((tx) => tx.id == updatedTransaction.id);
    if (index != -1) {
      transactions[index] = updatedTransaction;
      await saveTransactions(transactions);
    }
  }

  static Future<void> deleteTransaction(String transactionId) async {
    final transactions = await getTransactions();
    transactions.removeWhere((tx) => tx.id == transactionId);
    await saveTransactions(transactions);
  }

  // Recurring Transactions Management
  static Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final recurringTransactionsJson = _prefs?.getString(_recurringTransactionsKey);
    if (recurringTransactionsJson == null) return [];
    
    final List<dynamic> recurringTransactionsList = json.decode(recurringTransactionsJson);
    return recurringTransactionsList.map((json) => RecurringTransaction.fromJson(json)).toList();
  }

  static Future<void> saveRecurringTransactions(List<RecurringTransaction> recurringTransactions) async {
    final recurringTransactionsJson = json.encode(recurringTransactions.map((rt) => rt.toJson()).toList());
    await setValue(_recurringTransactionsKey, recurringTransactionsJson);
  }

  static Future<void> addRecurringTransaction(RecurringTransaction recurringTransaction) async {
    final recurringTransactions = await getRecurringTransactions();
    recurringTransactions.add(recurringTransaction);
    await saveRecurringTransactions(recurringTransactions);
  }

  static Future<void> updateRecurringTransaction(RecurringTransaction updatedRecurringTransaction) async {
    final recurringTransactions = await getRecurringTransactions();
    final index = recurringTransactions.indexWhere((rt) => rt.id == updatedRecurringTransaction.id);
    if (index != -1) {
      recurringTransactions[index] = updatedRecurringTransaction;
      await saveRecurringTransactions(recurringTransactions);
    }
  }

  static Future<void> deleteRecurringTransaction(String recurringTransactionId) async {
    final recurringTransactions = await getRecurringTransactions();
    recurringTransactions.removeWhere((rt) => rt.id == recurringTransactionId);
    await saveRecurringTransactions(recurringTransactions);
  }

  static Future<RecurringTransaction?> getRecurringTransactionById(String id) async {
    final recurringTransactions = await getRecurringTransactions();
    try {
      return recurringTransactions.firstWhere((rt) => rt.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<RecurringTransaction>> getActiveRecurringTransactions() async {
    final recurringTransactions = await getRecurringTransactions();
    return recurringTransactions.where((rt) => rt.isActive).toList();
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
    await setValue(_budgetsKey, budgetsJson);
  }

  // App State Management
  static bool get isFirstRun {
    return _prefs?.getBool(_firstRunKey) ?? true;
  }

  static Future<void> markFirstRunComplete() async {
    await _prefs?.setBool(_firstRunKey, false);
  }

  static Future<void> deduplicateTransactions() async {
    final transactions = await getTransactions();
    final Map<String, Transaction> uniqueTransactions = {};
    for (final tx in transactions) {
      uniqueTransactions[tx.id] = tx;
    }
    await saveTransactions(uniqueTransactions.values.toList());
  }
}