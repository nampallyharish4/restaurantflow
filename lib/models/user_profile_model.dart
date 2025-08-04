class UserProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      role: map['role'] ?? 'waiter',
      phone: map['phone'],
      isActive: map['is_active'] ?? true,
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
