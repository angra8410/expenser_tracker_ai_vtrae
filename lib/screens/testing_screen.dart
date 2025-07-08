import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/web_storage_service.dart';

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
      appBar: AppBar(
        title: const Text('Transactions (No Test Data)'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading transactions: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions yet. Add some expenses or income!'));
          }

          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  leading: Icon(
                    tx.amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                    color: tx.amount >= 0 ? Colors.green : Colors.red,
                  ),
                  title: Text(tx.description),
                  subtitle: Text(
                    '${tx.categoryId.isNotEmpty ? tx.categoryId : "No Category"} • ${_formatDate(tx.date)}',
                  ),
                  trailing: Text(
                    '${tx.amount >= 0 ? "+" : "-"}\$${tx.amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: tx.amount >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2,"0")}-${date.day.toString().padLeft(2,"0")}';
  }

  @override
  bool get wantKeepAlive => true;
}