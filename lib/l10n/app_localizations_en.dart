// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart AI Expense Tracker';

  @override
  String get home => 'Home';

  @override
  String get add => 'Add';

  @override
  String get analytics => 'Analytics';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get testing => 'Testing';

  @override
  String get settings => 'Settings';

  @override
  String welcomeBack(String username) {
    return '👋 Welcome back, $username!';
  }

  @override
  String get smartFinancialIntelligence =>
      'Smart Financial Intelligence at your fingertips';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get transactions => 'Transactions';

  @override
  String get realTransactions => 'real';

  @override
  String get quickActions => '⚡ Quick Actions';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get addTransactionDesc => 'Record new income or expense';

  @override
  String get viewAnalytics => 'View Analytics';

  @override
  String get viewAnalyticsDesc => 'See spending trends and insights';

  @override
  String get aiInsightsDesc => 'Smart financial intelligence';

  @override
  String get testLab => 'Test Lab';

  @override
  String get testLabDesc => 'Generate test data for AI';

  @override
  String get recentTransactions => '📊 Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get addFirstTransaction =>
      'Add your first transaction or generate test data';

  @override
  String get testData => 'Test Data';

  @override
  String get smartAIIntelligence => '🧠 Smart AI Intelligence';

  @override
  String get getIntelligentInsights =>
      'Get intelligent insights into your spending patterns';

  @override
  String get weekendAnalysis => '• Weekend vs weekday analysis';

  @override
  String get categoryTrends => '• Category spending trends';

  @override
  String get recurringDetection => '• Recurring transaction detection';

  @override
  String get anomalyAlerts => '• Anomaly alerts and predictions';

  @override
  String get exploreAIInsights => 'Explore AI Insights';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get addIncomeExpense => 'Add income or expense to track with Smart AI';

  @override
  String get transactionType => 'Transaction Type';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get whatWasThisFor => 'What was this transaction for?';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get date => 'Date';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get pleaseEnterDescription => 'Please enter a description';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get saving => 'Saving...';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get addIncome => 'Add Income';

  @override
  String expenseAdded(String amount) {
    return 'Expense of $amount added!';
  }

  @override
  String incomeAdded(String amount) {
    return 'Income of $amount added!';
  }

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get usDollar => 'US Dollar';

  @override
  String get colombianPeso => 'Colombian Peso';

  @override
  String get appearance => 'Appearance';

  @override
  String get localization => 'Localization';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get chooseCurrency => 'Choose your currency';

  @override
  String get chooseTheme => 'Choose your theme';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get loadingCategories => 'Loading categories...';

  @override
  String readyTransactions(int count) {
    return 'Ready! $count categories loaded';
  }

  @override
  String get coffee => 'Coffee';

  @override
  String get lunch => 'Lunch';

  @override
  String get gas => 'Gas';

  @override
  String get salary => 'Salary';

  @override
  String get grocery => 'Grocery';

  @override
  String get movie => 'Movie';
}
