import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/table_model.dart';
import './supabase_service.dart';

/// Service for managing restaurant tables
class TableService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Gets all tables with optional status filter
  /// [status] - Optional status filter (available, occupied, reserved, maintenance)
  /// Returns list of TableModel
  Future<List<TableModel>> getTables({String? status}) async {
    try {
      var query = _client.from('tables').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('table_number', ascending: true);

      return response
          .map<TableModel>((table) => TableModel.fromMap(table))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch tables: $error');
    }
  }

  /// Gets available tables
  /// Returns list of available TableModel
  Future<List<TableModel>> getAvailableTables() async {
    try {
      return await getTables(status: 'available');
    } catch (error) {
      throw Exception('Failed to fetch available tables: $error');
    }
  }

  /// Gets occupied tables
  /// Returns list of occupied TableModel
  Future<List<TableModel>> getOccupiedTables() async {
    try {
      return await getTables(status: 'occupied');
    } catch (error) {
      throw Exception('Failed to fetch occupied tables: $error');
    }
  }

  /// Gets a single table by ID
  /// [tableId] - ID of the table
  /// Returns TableModel or null if not found
  Future<TableModel?> getTableById(String tableId) async {
    try {
      final response =
          await _client.from('tables').select().eq('id', tableId).maybeSingle();

      return response != null ? TableModel.fromMap(response) : null;
    } catch (error) {
      throw Exception('Failed to fetch table: $error');
    }
  }

  /// Gets a table by table number
  /// [tableNumber] - Table number
  /// Returns TableModel or null if not found
  Future<TableModel?> getTableByNumber(int tableNumber) async {
    try {
      final response = await _client
          .from('tables')
          .select()
          .eq('table_number', tableNumber)
          .maybeSingle();

      return response != null ? TableModel.fromMap(response) : null;
    } catch (error) {
      throw Exception('Failed to fetch table by number: $error');
    }
  }

  /// Updates table status
  /// [tableId] - ID of the table
  /// [newStatus] - New status (available, occupied, reserved, maintenance)
  /// Returns updated TableModel
  Future<TableModel> updateTableStatus(String tableId, String newStatus) async {
    try {
      final response = await _client
          .from('tables')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', tableId)
          .select()
          .single();

      return TableModel.fromMap(response);
    } catch (error) {
      throw Exception('Failed to update table status: $error');
    }
  }

  /// Marks table as occupied
  /// [tableId] - ID of the table
  /// Returns updated TableModel
  Future<TableModel> occupyTable(String tableId) async {
    try {
      return await updateTableStatus(tableId, 'occupied');
    } catch (error) {
      throw Exception('Failed to occupy table: $error');
    }
  }

  /// Marks table as available
  /// [tableId] - ID of the table
  /// Returns updated TableModel
  Future<TableModel> freeTable(String tableId) async {
    try {
      return await updateTableStatus(tableId, 'available');
    } catch (error) {
      throw Exception('Failed to free table: $error');
    }
  }

  /// Reserves a table
  /// [tableId] - ID of the table
  /// Returns updated TableModel
  Future<TableModel> reserveTable(String tableId) async {
    try {
      return await updateTableStatus(tableId, 'reserved');
    } catch (error) {
      throw Exception('Failed to reserve table: $error');
    }
  }

  /// Marks table for maintenance
  /// [tableId] - ID of the table
  /// Returns updated TableModel
  Future<TableModel> setTableMaintenance(String tableId) async {
    try {
      return await updateTableStatus(tableId, 'maintenance');
    } catch (error) {
      throw Exception('Failed to set table maintenance: $error');
    }
  }

  /// Creates a new table (admin only)
  /// [tableNumber] - Table number
  /// [capacity] - Table capacity
  /// [location] - Optional location description
  /// Returns created TableModel
  Future<TableModel> createTable({
    required int tableNumber,
    required int capacity,
    String? location,
  }) async {
    try {
      final response = await _client
          .from('tables')
          .insert({
            'table_number': tableNumber,
            'capacity': capacity,
            'location': location,
            'status': 'available',
          })
          .select()
          .single();

      return TableModel.fromMap(response);
    } catch (error) {
      throw Exception('Failed to create table: $error');
    }
  }

  /// Updates table details (admin only)
  /// [tableId] - ID of the table
  /// [tableNumber] - New table number
  /// [capacity] - New capacity
  /// [location] - New location
  /// Returns updated TableModel
  Future<TableModel> updateTable({
    required String tableId,
    int? tableNumber,
    int? capacity,
    String? location,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (tableNumber != null) updates['table_number'] = tableNumber;
      if (capacity != null) updates['capacity'] = capacity;
      if (location != null) updates['location'] = location;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('tables')
          .update(updates)
          .eq('id', tableId)
          .select()
          .single();

      return TableModel.fromMap(response);
    } catch (error) {
      throw Exception('Failed to update table: $error');
    }
  }

  /// Deletes a table (admin only)
  /// [tableId] - ID of the table
  /// Returns true if successful
  Future<bool> deleteTable(String tableId) async {
    try {
      await _client.from('tables').delete().eq('id', tableId);

      return true;
    } catch (error) {
      throw Exception('Failed to delete table: $error');
    }
  }

  /// Gets table statistics
  /// Returns statistics about table utilization
  Future<Map<String, dynamic>> getTableStatistics() async {
    try {
      final response = await _client.from('tables').select('status');

      Map<String, int> statusCounts = {};
      int totalTables = response.length;

      for (var table in response) {
        String status = table['status'] ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return {
        'total_tables': totalTables,
        'available_tables': statusCounts['available'] ?? 0,
        'occupied_tables': statusCounts['occupied'] ?? 0,
        'reserved_tables': statusCounts['reserved'] ?? 0,
        'maintenance_tables': statusCounts['maintenance'] ?? 0,
        'occupancy_rate': totalTables > 0
            ? ((statusCounts['occupied'] ?? 0) / totalTables * 100).round()
            : 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch table statistics: $error');
    }
  }

  /// Gets current orders for a table
  /// [tableId] - ID of the table
  /// Returns list of orders for the table
  Future<List<Map<String, dynamic>>> getTableOrders(String tableId) async {
    try {
      final response = await _client
          .from('orders')
          .select(
              '*, order_items(*, menu_items(name)), user_profiles!waiter_id(full_name)')
          .eq('table_id', tableId)
          .neq('status', 'delivered')
          .neq('status', 'cancelled')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch table orders: $error');
    }
  }

  /// Gets table capacity summary
  /// Returns summary of table capacities
  Future<Map<String, dynamic>> getTableCapacitySummary() async {
    try {
      final response = await _client.from('tables').select('capacity, status');

      int totalCapacity = 0;
      int availableCapacity = 0;
      Map<int, int> capacityDistribution = {};

      for (var table in response) {
        int capacity = table['capacity'] ?? 0;
        String status = table['status'] ?? 'unknown';

        totalCapacity += capacity;
        if (status == 'available') {
          availableCapacity += capacity;
        }

        capacityDistribution[capacity] =
            (capacityDistribution[capacity] ?? 0) + 1;
      }

      return {
        'total_capacity': totalCapacity,
        'available_capacity': availableCapacity,
        'utilized_capacity': totalCapacity - availableCapacity,
        'capacity_distribution': capacityDistribution,
        'utilization_percentage': totalCapacity > 0
            ? ((totalCapacity - availableCapacity) / totalCapacity * 100)
                .round()
            : 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch table capacity summary: $error');
    }
  }

  /// Subscribes to real-time table status changes
  /// [callback] - Function to handle table updates
  /// Returns RealtimeChannel for managing subscription
  RealtimeChannel subscribeToTables(Function(Map<String, dynamic>) callback) {
    return _client
        .channel('public:tables')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tables',
          callback: (payload) async {
            callback(payload.newRecord ?? payload.oldRecord ?? {});
          },
        )
        .subscribe();
  }
}
