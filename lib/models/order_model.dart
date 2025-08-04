class OrderModel {
  final String id;
  final String orderNumber;
  final String? tableId;
  final String? waiterId;
  final String? customerName;
  final String? customerPhone;
  final String status;
  final String paymentStatus;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? deliveredAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.tableId,
    this.waiterId,
    this.customerName,
    this.customerPhone,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.specialRequests,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.deliveredAt,
    this.items = const [],
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      orderNumber: map['order_number'] ?? '',
      tableId: map['table_id'],
      waiterId: map['waiter_id'],
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      status: map['status'] ?? 'pending',
      paymentStatus: map['payment_status'] ?? 'pending',
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      taxAmount: (map['tax_amount'] ?? 0).toDouble(),
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      specialRequests: map['special_requests'],
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
      confirmedAt: map['confirmed_at'] != null
          ? DateTime.parse(map['confirmed_at'])
          : null,
      deliveredAt: map['delivered_at'] != null
          ? DateTime.parse(map['delivered_at'])
          : null,
      items: (map['order_items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromMap(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'table_id': tableId,
      'waiter_id': waiterId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'status': status,
      'payment_status': paymentStatus,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'special_requests': specialRequests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }
}

class OrderItemModel {
  final String id;
  final String orderId;
  final String menuItemId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? specialInstructions;
  final String status;
  final DateTime createdAt;
  final MenuItemModel? menuItem;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    required this.status,
    required this.createdAt,
    this.menuItem,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] ?? '',
      orderId: map['order_id'] ?? '',
      menuItemId: map['menu_item_id'] ?? '',
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unit_price'] ?? 0).toDouble(),
      totalPrice: (map['total_price'] ?? 0).toDouble(),
      specialInstructions: map['special_instructions'],
      status: map['status'] ?? 'pending',
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      menuItem: map['menu_items'] != null
          ? MenuItemModel.fromMap(map['menu_items'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'special_instructions': specialInstructions,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MenuItemModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? categoryId;
  final String? imageUrl;
  final bool isAvailable;
  final bool isVegetarian;
  final bool isVegan;
  final bool isSpicy;
  final int preparationTime;
  final List<String> allergens;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.categoryId,
    this.imageUrl,
    required this.isAvailable,
    required this.isVegetarian,
    required this.isVegan,
    required this.isSpicy,
    required this.preparationTime,
    this.allergens = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      price: (map['price'] ?? 0).toDouble(),
      categoryId: map['category_id'],
      imageUrl: map['image_url'],
      isAvailable: map['is_available'] ?? true,
      isVegetarian: map['is_vegetarian'] ?? false,
      isVegan: map['is_vegan'] ?? false,
      isSpicy: map['is_spicy'] ?? false,
      preparationTime: map['preparation_time'] ?? 15,
      allergens: (map['allergens'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'is_vegetarian': isVegetarian,
      'is_vegan': isVegan,
      'is_spicy': isSpicy,
      'preparation_time': preparationTime,
      'allergens': allergens,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
