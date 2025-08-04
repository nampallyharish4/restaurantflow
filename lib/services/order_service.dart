import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_model.dart';
import './supabase_service.dart';

/// Service for managing restaurant orders
class OrderService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Creates a new order
  /// [tableId] - ID of the table
  /// [customerName] - Customer's name
  /// [customerPhone] - Customer's phone number
  /// [specialRequests] - Special requests for the order
  /// Returns the created OrderModel
  Future<OrderModel> createOrder({
    required String tableId,
    required String customerName,
    String? customerPhone,
    String? specialRequests,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('orders')
          .insert({
            'table_id': tableId,
            'waiter_id': currentUser.id,
            'customer_name': customerName,
            'customer_phone': customerPhone,
            'special_requests': specialRequests,
            'status': 'pending',
            'payment_status': 'pending',
          })
          .select()
          .single();

      return OrderModel.fromMap(response);
    } catch (error) {
      throw Exception('Failed to create order: $error');
    }
  }

  /// Gets all orders with optional filters
  /// [status] - Filter by order status
  /// [waiterId] - Filter by waiter ID
  /// [tableId] - Filter by table ID
  /// [limit] - Number of orders to fetch
  /// Returns list of OrderModel
  Future<List<OrderModel>> getOrders({
    String? status,
    String? waiterId,
    String? tableId,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('orders').select(
          '*, order_items(*, menu_items(*)), tables(*), user_profiles!waiter_id(full_name)');

      if (status != null) {
        query = query.eq('status', status);
      }
      if (waiterId != null) {
        query = query.eq('waiter_id', waiterId);
      }
      if (tableId != null) {
        query = query.eq('table_id', tableId);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return response
          .map<OrderModel>((order) => OrderModel.fromMap(order))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch orders: $error');
    }
  }

  /// Gets orders for the current waiter
  /// [status] - Optional status filter
  /// Returns list of OrderModel
  Future<List<OrderModel>> getMyOrders({String? status}) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      return await getOrders(waiterId: currentUser.id, status: status);
    } catch (error) {
      throw Exception('Failed to fetch my orders: $error');
    }
  }

  /// Gets a single order by ID
  /// [orderId] - ID of the order
  /// Returns OrderModel or null if not found
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final response = await _client
          .from('orders')
          .select(
              '*, order_items(*, menu_items(*)), tables(*), user_profiles!waiter_id(full_name)')
          .eq('id', orderId)
          .maybeSingle();

      return response != null ? OrderModel.fromMap(response) : null;
    } catch (error) {
      throw Exception('Failed to fetch order: $error');
    }
  }

  /// Updates order status
  /// [orderId] - ID of the order
  /// [newStatus] - New status for the order
  /// [notes] - Optional notes for the status change
  /// Returns updated OrderModel
  Future<OrderModel> updateOrderStatus(String orderId, String newStatus,
      {String? notes}) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // First get current order to track status change
      final currentOrder = await getOrderById(orderId);
      if (currentOrder == null) {
        throw Exception('Order not found');
      }

      // Update order status
      final response = await _client
          .from('orders')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
            if (newStatus == 'confirmed')
              'confirmed_at': DateTime.now().toIso8601String(),
            if (newStatus == 'delivered')
              'delivered_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .select(
              '*, order_items(*, menu_items(*)), tables(*), user_profiles!waiter_id(full_name)')
          .single();

      // Add status history entry
      await _client.from('order_status_history').insert({
        'order_id': orderId,
        'previous_status': currentOrder.status,
        'new_status': newStatus,
        'changed_by': currentUser.id,
        'notes': notes,
      });

      return OrderModel.fromMap(response);
    } catch (error) {
      throw Exception('Failed to update order status: $error');
    }
  }

  /// Adds an item to an order
  /// [orderId] - ID of the order
  /// [menuItemId] - ID of the menu item
  /// [quantity] - Quantity of the item
  /// [specialInstructions] - Special instructions for the item
  /// Returns true if successful
  Future<bool> addOrderItem({
    required String orderId,
    required String menuItemId,
    required int quantity,
    String? specialInstructions,
  }) async {
    try {
      // Get menu item price
      final menuItem = await _client
          .from('menu_items')
          .select('price')
          .eq('id', menuItemId)
          .single();

      final unitPrice = (menuItem['price'] as num).toDouble();
      final totalPrice = unitPrice * quantity;

      await _client.from('order_items').insert({
        'order_id': orderId,
        'menu_item_id': menuItemId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        'special_instructions': specialInstructions,
        'status': 'pending',
      });

      return true;
    } catch (error) {
      throw Exception('Failed to add order item: $error');
    }
  }

  /// Removes an item from an order
  /// [orderItemId] - ID of the order item
  /// Returns true if successful
  Future<bool> removeOrderItem(String orderItemId) async {
    try {
      await _client.from('order_items').delete().eq('id', orderItemId);

      return true;
    } catch (error) {
      throw Exception('Failed to remove order item: $error');
    }
  }

  /// Updates order item quantity
  /// [orderItemId] - ID of the order item
  /// [newQuantity] - New quantity
  /// Returns true if successful
  Future<bool> updateOrderItemQuantity(
      String orderItemId, int newQuantity) async {
    try {
      // Get current order item
      final orderItem = await _client
          .from('order_items')
          .select('unit_price')
          .eq('id', orderItemId)
          .single();

      final unitPrice = (orderItem['unit_price'] as num).toDouble();
      final totalPrice = unitPrice * newQuantity;

      await _client.from('order_items').update({
        'quantity': newQuantity,
        'total_price': totalPrice,
      }).eq('id', orderItemId);

      return true;
    } catch (error) {
      throw Exception('Failed to update order item quantity: $error');
    }
  }

  /// Gets order status history
  /// [orderId] - ID of the order
  /// Returns list of status history entries
  Future<List<Map<String, dynamic>>> getOrderHistory(String orderId) async {
    try {
      final response = await _client
          .from('order_status_history')
          .select('*, user_profiles!changed_by(full_name)')
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch order history: $error');
    }
  }

  /// Gets orders by status for kitchen/counter dashboard
  /// [statuses] - List of statuses to filter by
  /// Returns list of OrderModel
  Future<List<OrderModel>> getOrdersByStatus(List<String> statuses) async {
    try {
      final response = await _client
          .from('orders')
          .select(
              '*, order_items(*, menu_items(*)), tables(*), user_profiles!waiter_id(full_name)')
          .inFilter('status', statuses)
          .order('created_at', ascending: true);

      return response
          .map<OrderModel>((order) => OrderModel.fromMap(order))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch orders by status: $error');
    }
  }

  /// Cancels an order
  /// [orderId] - ID of the order
  /// [reason] - Reason for cancellation
  /// Returns true if successful
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await updateOrderStatus(orderId, 'cancelled', notes: reason);
      return true;
    } catch (error) {
      throw Exception('Failed to cancel order: $error');
    }
  }

  /// Subscribes to real-time order changes
  /// [callback] - Function to handle order updates
  /// Returns RealtimeChannel for managing subscription
  RealtimeChannel subscribeToOrders(Function(Map<String, dynamic>) callback) {
    return _client
        .channel('public:orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) async {
            callback(payload.newRecord ?? payload.oldRecord ?? {});
          },
        )
        .subscribe();
  }

  /// Gets order statistics for dashboard
  /// [date] - Date to get statistics for (defaults to today)
  /// Returns statistics map
  Future<Map<String, dynamic>> getOrderStatistics({DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateString = targetDate.toIso8601String().split('T')[0];

      final todayOrders = await _client
          .from('orders')
          .select('status, total_amount')
          .gte('created_at', '${dateString}T00:00:00')
          .lt('created_at', '${dateString}T23:59:59');

      int totalOrders = todayOrders.length;
      double totalRevenue = 0;
      Map<String, int> statusCounts = {};

      for (var order in todayOrders) {
        totalRevenue += (order['total_amount'] as num?)?.toDouble() ?? 0;
        String status = order['status'] ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return {
        'total_orders': totalOrders,
        'total_revenue': totalRevenue,
        'average_order_value': totalOrders > 0 ? totalRevenue / totalOrders : 0,
        'status_counts': statusCounts,
        'pending_orders': statusCounts['pending'] ?? 0,
        'confirmed_orders': statusCounts['confirmed'] ?? 0,
        'preparing_orders': statusCounts['preparing'] ?? 0,
        'ready_orders': statusCounts['ready'] ?? 0,
        'delivered_orders': statusCounts['delivered'] ?? 0,
        'cancelled_orders': statusCounts['cancelled'] ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch order statistics: $error');
    }
  }
}
