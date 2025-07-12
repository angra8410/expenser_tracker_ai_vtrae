import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/web_storage_service.dart';
import '../services/export_service.dart';
import '../widgets/edit_transaction_dialog.dart';

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
      _transactionsFuture = WebStorageService.getTransactions(includeTestData: false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Note: Removed automatic reload to prevent duplications
    // Use the refresh button to manually reload if needed
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Needed for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Transactions',
            onSelected: _handleExport,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'json',
                child: Row(
                  children: [
                    Icon(Icons.code, size: 18),
                    SizedBox(width: 8),
                    Text('Export as JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 18),
                    SizedBox(width: 8),
                    Text('Export as CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.grid_on, size: 18),
                    SizedBox(width: 8),
                    Text('Export as Excel'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Transactions',
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
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
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: tx.type == TransactionType.income ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            tx.type == TransactionType.income ? Icons.add_circle : Icons.remove_circle,
                            color: tx.type == TransactionType.income ? Colors.green[600] : Colors.red[600],
                            size: 20,
                          ),
                        ),
                        title: Text(tx.description),
                        subtitle: Text(
                          '${tx.categoryId.isNotEmpty ? tx.categoryId : "No Category"} • ${_formatDate(tx.date)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${tx.type == TransactionType.income ? "+" : "-"}\$${tx.amount.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                color: tx.type == TransactionType.income ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                        onTap: () => _editTransaction(tx),
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

  Future<void> _editTransaction(Transaction transaction) async {
    await showDialog(
      context: context,
      builder: (context) => EditTransactionDialog(
        transaction: transaction,
        onTransactionUpdated: (updatedTransaction) {
          _loadTransactions();
        },
        onTransactionDeleted: () {
          _loadTransactions();
        },
      ),
    );
  }

  Future<void> _handleExport(String format) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting transactions...'),
            ],
          ),
        ),
      );

      // Perform export based on format
      switch (format) {
        case 'json':
          await ExportService.exportToJson();
          break;
        case 'csv':
          await ExportService.exportToCsv();
          break;
        case 'excel':
          await ExportService.exportToExcel();
          break;
      }

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transactions exported as ${format.toUpperCase()} successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}