// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Rastreador Inteligente de Gastos AI';

  @override
  String get home => 'Inicio';

  @override
  String get add => 'Agregar';

  @override
  String get analytics => 'Análisis';

  @override
  String get aiInsights => 'IA Inteligente';

  @override
  String get testing => 'Pruebas';

  @override
  String get settings => 'Ajustes';

  @override
  String welcomeBack(String username) {
    return '👋 ¡Bienvenido de nuevo, $username!';
  }

  @override
  String get smartFinancialIntelligence =>
      'Inteligencia financiera inteligente al alcance de tus manos';

  @override
  String get totalIncome => 'Ingresos Totales';

  @override
  String get totalExpenses => 'Gastos Totales';

  @override
  String get netBalance => 'Balance Neto';

  @override
  String get transactions => 'Transacciones';

  @override
  String get realTransactions => 'reales';

  @override
  String get quickActions => '⚡ Acciones Rápidas';

  @override
  String get addTransaction => 'Agregar Transacción';

  @override
  String get addTransactionDesc => 'Registrar nuevo ingreso o gasto';

  @override
  String get viewAnalytics => 'Ver Análisis';

  @override
  String get viewAnalyticsDesc => 'Ver tendencias e insights de gastos';

  @override
  String get aiInsightsDesc => 'Inteligencia financiera inteligente';

  @override
  String get testLab => 'Laboratorio de Pruebas';

  @override
  String get testLabDesc => 'Generar datos de prueba para IA';

  @override
  String get recentTransactions => '📊 Transacciones Recientes';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get noTransactionsYet => 'No hay transacciones aún';

  @override
  String get addFirstTransaction =>
      'Agrega tu primera transacción o genera datos de prueba';

  @override
  String get testData => 'Datos de Prueba';

  @override
  String get smartAIIntelligence => '🧠 Inteligencia AI Inteligente';

  @override
  String get getIntelligentInsights =>
      'Obtén insights inteligentes sobre tus patrones de gasto';

  @override
  String get weekendAnalysis => '• Análisis fin de semana vs días laborales';

  @override
  String get categoryTrends => '• Tendencias de gasto por categoría';

  @override
  String get recurringDetection => '• Detección de transacciones recurrentes';

  @override
  String get anomalyAlerts => '• Alertas de anomalías y predicciones';

  @override
  String get exploreAIInsights => 'Explorar Insights de IA';

  @override
  String get newTransaction => 'Nueva Transacción';

  @override
  String get addIncomeExpense =>
      'Agregar ingreso o gasto para rastrear con IA Inteligente';

  @override
  String get transactionType => 'Tipo de Transacción';

  @override
  String get expense => 'Gasto';

  @override
  String get income => 'Ingreso';

  @override
  String get amount => 'Cantidad';

  @override
  String get description => 'Descripción';

  @override
  String get whatWasThisFor => '¿Para qué fue esta transacción?';

  @override
  String get category => 'Categoría';

  @override
  String get selectCategory => 'Selecciona una categoría';

  @override
  String get date => 'Fecha';

  @override
  String get pleaseEnterAmount => 'Por favor ingresa una cantidad';

  @override
  String get pleaseEnterValidAmount => 'Por favor ingresa una cantidad válida';

  @override
  String get pleaseEnterDescription => 'Por favor ingresa una descripción';

  @override
  String get pleaseSelectCategory => 'Por favor selecciona una categoría';

  @override
  String get saving => 'Guardando...';

  @override
  String get addExpense => 'Agregar Gasto';

  @override
  String get addIncome => 'Agregar Ingreso';

  @override
  String expenseAdded(String amount) {
    return '¡Gasto de $amount agregado!';
  }

  @override
  String incomeAdded(String amount) {
    return '¡Ingreso de $amount agregado!';
  }

  @override
  String get language => 'Idioma';

  @override
  String get currency => 'Moneda';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get usDollar => 'Dólar Estadounidense';

  @override
  String get colombianPeso => 'Peso Colombiano';

  @override
  String get appearance => 'Apariencia';

  @override
  String get localization => 'Localización';

  @override
  String get chooseLanguage => 'Elige tu idioma';

  @override
  String get chooseCurrency => 'Elige tu moneda';

  @override
  String get chooseTheme => 'Elige tu tema';

  @override
  String get refreshData => 'Actualizar Datos';

  @override
  String get loadingCategories => 'Cargando categorías...';

  @override
  String readyTransactions(int count) {
    return '¡Listo! $count categorías cargadas';
  }

  @override
  String get coffee => 'Café';

  @override
  String get lunch => 'Almuerzo';

  @override
  String get gas => 'Gasolina';

  @override
  String get salary => 'Salario';

  @override
  String get grocery => 'Mercado';

  @override
  String get movie => 'Película';
}
