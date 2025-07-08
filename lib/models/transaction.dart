enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String id;
  final double amount;
  final String description;
  final String categoryId;
  final DateTime date;
  final TransactionType type;
  final String accountId;
  final DateTime? createdAt;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
    required this.type,
    required this.accountId,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'account_id': accountId,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      type: json['type'] == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
      accountId: json['account_id'] ?? 'personal',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    String? categoryId,
    DateTime? date,
    TransactionType? type,
    String? accountId,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, description: $description, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}