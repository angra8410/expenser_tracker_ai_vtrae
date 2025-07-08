import 'package:flutter/material.dart';
import '../services/web_storage_service.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  Map<String, double> _budgets = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await WebStorageService.getTransactions();
      final categories = await WebStorageService.getCategories();
      final budgets = await WebStorageService.getBudgets();

      setState(() {
        _transactions = transactions;
        _categories = categories;
        _budgets = budgets;
      });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, double> _getCategorySpending() {
    final categorySpending = <String, double>{};
    
    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        categorySpending[transaction.categoryId] =
            (categorySpending[transaction.categoryId] ?? 0) + transaction.amount;
      }
    }
    
    return categorySpending;
  }

  Map<String, double> _getMonthlySpending() {
    final monthlySpending = <String, double>{};
    
    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
        monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0) + transaction.amount;
      }
    }
    
    return monthlySpending;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('📊 Analytics'),
          backgroundColor: Colors.orange[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final totalExpenses = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalIncome = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('📊 Analytics (${_transactions.length} transactions)'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.orange[200],
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'Overview'),
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(totalIncome, totalExpenses),
          _buildCategoriesTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(double totalIncome, double totalExpenses) {
    final netCashFlow = totalIncome - totalExpenses;
    final savingsRate = totalIncome > 0 ? (netCashFlow / totalIncome) * 100 : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Income',
                  '\$${totalIncome.toStringAsFixed(2)}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Expenses',
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Net Cash Flow',
                  '\$${netCashFlow.toStringAsFixed(2)}',
                  netCashFlow >= 0 ? Icons.account_balance_wallet : Icons.warning,
                  netCashFlow >= 0 ? Colors.blue : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Savings Rate',
                  '${savingsRate.toStringAsFixed(1)}%',
                  Icons.savings,
                  savingsRate > 20 ? Colors.green : savingsRate > 10 ? Colors.orange : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[600]!, Colors.orange[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📈 Quick Financial Snapshot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickStat('Transactions This Month', '${_transactions.length}'),
                _buildQuickStat('Average Transaction', '\$${_transactions.isNotEmpty ? (totalExpenses / _transactions.where((t) => t.type == TransactionType.expense).length).toStringAsFixed(2) : "0.00"}'),
                _buildQuickStat('Categories Used', '${_getCategorySpending().keys.length}'),
                _buildQuickStat('Days Tracked', '${_getActiveDays()}'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Financial Health Indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getHealthColor(savingsRate).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getHealthColor(savingsRate).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _getHealthIcon(savingsRate),
                  size: 48,
                  color: _getHealthColor(savingsRate),
                ),
                const SizedBox(height: 12),
                Text(
                  _getHealthTitle(savingsRate),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getHealthColor(savingsRate),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getHealthDescription(savingsRate, netCashFlow),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final categorySpending = _getCategorySpending();
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Category Breakdown Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pie_chart, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Spending by Category',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'See where your money goes each month',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Category List
          ...sortedCategories.map((entry) {
            final category = _categories.firstWhere(
              (c) => c.id == entry.key,
              orElse: () => Category(id: entry.key, name: 'Unknown', icon: '❓', color: 'FF9E9E9E'),
            );
            final budget = _budgets[entry.key] ?? 0;
            final percentage = budget > 0 ? (entry.value / budget) * 100 : 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${entry.value.toStringAsFixed(2)} spent',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (budget > 0) ...[
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: percentage > 100 
                                    ? Colors.red 
                                    : percentage > 80 
                                        ? Colors.orange 
                                        : Colors.green,
                              ),
                            ),
                            Text(
                              'of \$${budget.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ] else ...[
                            Text(
                              'No Budget',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (budget > 0) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        percentage > 100 
                            ? Colors.red 
                            : percentage > 80 
                                ? Colors.orange 
                                : Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    final monthlySpending = _getMonthlySpending();
    final sortedMonths = monthlySpending.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Trends Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.purple[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Spending Trends Over Time',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your spending patterns month by month',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Monthly Trend Cards
          ...sortedMonths.map((entry) {
            final monthName = _getMonthName(entry.key);
            final isCurrentMonth = entry.key == '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrentMonth ? Colors.blue[50] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrentMonth ? Colors.blue[200]! : Colors.grey[200]!,
                  width: isCurrentMonth ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCurrentMonth ? Colors.blue[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      isCurrentMonth ? Icons.today : Icons.calendar_month,
                      color: isCurrentMonth ? Colors.blue[600] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCurrentMonth ? Colors.blue[800] : Colors.black,
                          ),
                        ),
                        Text(
                          'Total spending this month',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCurrentMonth ? Colors.blue[700] : Colors.black,
                        ),
                      ),
                      if (isCurrentMonth)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Trend Insights
          if (sortedMonths.length >= 2) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Trend Insights',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getTrendInsight(sortedMonths),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _getActiveDays() {
    final uniqueDays = <String>{};
    for (final transaction in _transactions) {
      uniqueDays.add('${transaction.date.year}-${transaction.date.month}-${transaction.date.day}');
    }
    return uniqueDays.length;
  }

  Color _getHealthColor(double savingsRate) {
    if (savingsRate > 20) return Colors.green;
    if (savingsRate > 10) return Colors.orange;
    return Colors.red;
  }

  IconData _getHealthIcon(double savingsRate) {
    if (savingsRate > 20) return Icons.sentiment_very_satisfied;
    if (savingsRate > 10) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  String _getHealthTitle(double savingsRate) {
    if (savingsRate > 20) return 'Excellent Financial Health';
    if (savingsRate > 10) return 'Good Financial Health';
    if (savingsRate > 0) return 'Fair Financial Health';
    return 'Needs Attention';
  }

  String _getHealthDescription(double savingsRate, double netCashFlow) {
    if (savingsRate > 20) {
      return 'Outstanding! You\'re saving more than 20% of your income. Keep up the great work!';
    } else if (savingsRate > 10) {
      return 'Good job! You\'re saving a healthy amount. Consider increasing to 20% if possible.';
    } else if (netCashFlow > 0) {
      return 'You have positive cash flow but could improve your savings rate. Aim for 10-20%.';
    } else {
      return 'You\'re spending more than you earn. Time to review your expenses and create a budget.';
    }
  }

  String _getMonthName(String monthKey) {
    final parts = monthKey.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    
    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${monthNames[month]} $year';
  }

  String _getTrendInsight(List<MapEntry<String, double>> sortedMonths) {
    if (sortedMonths.length < 2) return '';
    
    final lastMonth = sortedMonths[sortedMonths.length - 2].value;
    final currentMonth = sortedMonths.last.value;
    final change = ((currentMonth - lastMonth) / lastMonth) * 100;
    
    if (change > 10) {
      return 'Your spending increased by ${change.toStringAsFixed(1)}% this month. Consider reviewing your recent expenses.';
    } else if (change < -10) {
      return 'Great job! Your spending decreased by ${change.abs().toStringAsFixed(1)}% this month. Keep up the good work!';
    } else {
      return 'Your spending is relatively stable compared to last month (${change.toStringAsFixed(1)}% change).';
    }
  }
}