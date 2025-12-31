class Expense {
  final String id;
  final String userId;
  final String? memberId;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Expense({
    required this.id,
    required this.userId,
    this.memberId,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'memberId': memberId,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      memberId: map['memberId'],
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Expense copyWith({
    String? id,
    String? userId,
    String? memberId,
    String? category,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      memberId: memberId ?? this.memberId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
