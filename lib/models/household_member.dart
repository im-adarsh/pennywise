class HouseholdMember {
  final String id;
  final String userId;
  final String name;
  final String? email;
  final String? phone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HouseholdMember({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory HouseholdMember.fromMap(Map<String, dynamic> map) {
    return HouseholdMember(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  HouseholdMember copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HouseholdMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
