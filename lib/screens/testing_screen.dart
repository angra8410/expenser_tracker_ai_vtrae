import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/web_storage_service.dart';
import '../utils/quick_test.dart';

class TestingScreen extends StatefulWidget {
  const TestingScreen({Key? key}) : super(key: key);

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> with AutomaticKeepAliveClientMixin {
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactionsFuture = WebStorageService.getTransactions();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when coming back to this tab
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Needed for AutomaticKeepAliveClientMixin
    return Scaffold(
      body: Column(
        children: [
          // Debug Controls
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔧 Debug Controls',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await QuickTest.testTransactionStorage();
                          _loadTransactions();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🧪 Test completed! Check console for details.'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.science),
                        label: const Text('Test Storage'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await QuickTest.clearAllData();
                          _loadTransactions();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🧹 All data cleared!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading transactions: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add some expenses or income, or run the storage test!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final transactions = snapshot.data!;
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isTest = tx.id.startsWith('test');
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isTest ? Colors.orange[100] : (tx.type == TransactionType.income ? Colors.green[100] : Colors.red[100]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isTest ? Icons.science : (tx.type == TransactionType.income ? Icons.add_circle : Icons.remove_circle),
                            color: isTest ? Colors.orange[600] : (tx.type == TransactionType.income ? Colors.green[600] : Colors.red[600]),
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(tx.description)),
                            if (isTest)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'TEST',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${tx.categoryId.isNotEmpty ? tx.categoryId : "No Category"} • ${_formatDate(tx.date)}',
                        ),
                        trailing: Text(
                          '${tx.type == TransactionType.income ? "+" : "-"}\$${tx.amount.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: tx.type == TransactionType.income ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2,"0")}-${date.day.toString().padLeft(2,"0")}';
  }

  @override
  bool get wantKeepAlive => true;
}