import '../services/web_storage_service.dart';
import '../services/transactions_service.dart';
import '../models/transaction.dart';

class QuickTest {
  static Future<void> testTransactionStorage() async {
    print('🧪 Testing Transaction Storage...');
    
    try {
      // Test WebStorageService
      print('\n📦 Testing WebStorageService...');
      final testTransaction = Transaction(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        amount: 100.0,
        description: 'Test Transaction',
        categoryId: 'food',
        date: DateTime.now(),
        type: TransactionType.expense,
        accountId: 'personal',
      );
      
      // Add transaction
      await WebStorageService.addTransaction(testTransaction);
      print('✅ Transaction added to WebStorageService');
      
      // Get transactions
      final webTransactions = await WebStorageService.getTransactions();
      print('📊 WebStorageService has ${webTransactions.length} transactions');
      
      // Test TransactionsService
      print('\n📦 Testing TransactionsService...');
      final testTransaction2 = Transaction(
        id: 'test2_${DateTime.now().millisecondsSinceEpoch}',
        amount: 200.0,
        description: 'Test Transaction 2',
        categoryId: 'transport',
        date: DateTime.now(),
        type: TransactionType.income,
        accountId: 'personal',
      );
      
      // Add transaction
      await TransactionsService.addTransaction(testTransaction2);
      print('✅ Transaction added to TransactionsService');
      
      // Get transactions
      final serviceTransactions = await TransactionsService.getTransactions();
      print('📊 TransactionsService has ${serviceTransactions.length} transactions');
      
      // Show all transactions from both services
      print('\n📋 All WebStorageService transactions:');
      for (final tx in webTransactions) {
        print('  - ${tx.description}: ${tx.amount} (${tx.type})');
      }
      
      print('\n📋 All TransactionsService transactions:');
      for (final tx in serviceTransactions) {
        print('  - ${tx.description}: ${tx.amount} (${tx.type})');
      }
      
    } catch (e) {
      print('❌ Error during test: $e');
    }
  }
  
  static Future<void> clearAllData() async {
    print('🧹 Clearing all transaction data...');
    try {
      await WebStorageService.clearAllData();
      await TransactionsService.clearAll();
      print('✅ All data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}
