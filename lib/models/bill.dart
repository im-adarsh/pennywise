class Bill {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final int dayOfMonth; // 1-31
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Bill({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.dayOfMonth,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'amount': amount,
      'dayOfMonth': dayOfMonth,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      dayOfMonth: map['dayOfMonth'] ?? 1,
      description: map['description'],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Bill copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    int? dayOfMonth,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
