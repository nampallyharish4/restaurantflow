class TableModel {
  final String id;
  final int tableNumber;
  final int capacity;
  final String status;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map['id'] ?? '',
      tableNumber: map['table_number'] ?? 0,
      capacity: map['capacity'] ?? 4,
      status: map['status'] ?? 'available',
      location: map['location'],
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_number': tableNumber,
      'capacity': capacity,
      'status': status,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TableModel copyWith({
    String? id,
    int? tableNumber,
    int? capacity,
    String? status,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
