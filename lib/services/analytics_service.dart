import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

/// Service for restaurant analytics and reporting
class AnalyticsService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Gets daily analytics for a specific date
  /// [date] - Date to get analytics for (defaults to today)
  /// Returns daily analytics data
  Future<Map<String, dynamic>?> getDailyAnalytics({DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd').format(targetDate);

      final response = await _client
          .from('daily_analytics')
          .select('*, menu_items!most_ordered_item_id(name)')
          .eq('date', dateString)
          .maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch daily analytics: $error');
    }
  }

  /// Gets analytics for a date range
  /// [startDate] - Start date
  /// [endDate] - End date
  /// Returns list of daily analytics
  Future<List<Map<String, dynamic>>> getAnalyticsRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final startDateString = DateFormat('yyyy-MM-dd').format(startDate);
      final endDateString = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await _client
          .from('daily_analytics')
          .select('*, menu_items!most_ordered_item_id(name)')
          .gte('date', startDateString)
          .lte('date', endDateString)
          .order('date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch analytics range: $error');
    }
  }

  /// Generates real-time analytics for today
  /// Returns current day statistics
  Future<Map<String, dynamic>> generateTodayAnalytics() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get today's orders
      final orders = await _client
          .from('orders')
          .select('total_amount, created_at, status')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      // Calculate statistics
      int totalOrders = orders.length;
      double totalRevenue = 0;
      Map<int, int> hourlyOrders = {};
      Map<String, int> statusCounts = {};

      for (var order in orders) {
        totalRevenue += (order['total_amount'] as num?)?.toDouble() ?? 0;

        String status = order['status'] ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;

        DateTime orderTime = DateTime.parse(order['created_at']);
        int hour = orderTime.hour;
        hourlyOrders[hour] = (hourlyOrders[hour] ?? 0) + 1;
      }

      // Find peak hour
      int peakHour = 0;
      int maxOrders = 0;
      hourlyOrders.forEach((hour, count) {
        if (count > maxOrders) {
          maxOrders = count;
          peakHour = hour;
        }
      });

      // Get most ordered item today
      final orderItems = await _client
          .from('order_items')
          .select('menu_item_id, quantity, menu_items(name)')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      Map<String, Map<String, dynamic>> itemCounts = {};
      for (var item in orderItems) {
        String menuItemId = item['menu_item_id'];
        int quantity = item['quantity'] ?? 0;

        if (itemCounts.containsKey(menuItemId)) {
          itemCounts[menuItemId]!['quantity'] += quantity;
        } else {
          itemCounts[menuItemId] = {
            'quantity': quantity,
            'menu_item': item['menu_items'],
          };
        }
      }

      String? mostOrderedItemId;
      Map<String, dynamic>? mostOrderedItem;
      int maxQuantity = 0;

      itemCounts.forEach((itemId, data) {
        if (data['quantity'] > maxQuantity) {
          maxQuantity = data['quantity'];
          mostOrderedItemId = itemId;
          mostOrderedItem = data['menu_item'];
        }
      });

      return {
        'date': DateFormat('yyyy-MM-dd').format(today),
        'total_orders': totalOrders,
        'total_revenue': totalRevenue,
        'average_order_value': totalOrders > 0 ? totalRevenue / totalOrders : 0,
        'peak_hour': peakHour,
        'most_ordered_item_id': mostOrderedItemId,
        'most_ordered_item': mostOrderedItem,
        'total_customers': totalOrders, // Assuming 1 customer per order
        'hourly_distribution': hourlyOrders,
        'status_distribution': statusCounts,
      };
    } catch (error) {
      throw Exception('Failed to generate today analytics: $error');
    }
  }

  /// Gets revenue analytics for a period
  /// [days] - Number of days to analyze (defaults to 30)
  /// Returns revenue analytics
  Future<Map<String, dynamic>> getRevenueAnalytics({int days = 30}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final analytics = await getAnalyticsRange(startDate, endDate);

      double totalRevenue = 0;
      double totalOrders = 0;
      List<Map<String, dynamic>> dailyRevenue = [];

      for (var day in analytics) {
        double dayRevenue = (day['total_revenue'] as num?)?.toDouble() ?? 0;
        int dayOrders = day['total_orders'] ?? 0;

        totalRevenue += dayRevenue;
        totalOrders += dayOrders;

        dailyRevenue.add({
          'date': day['date'],
          'revenue': dayRevenue,
          'orders': dayOrders,
          'average_order_value': dayOrders > 0 ? dayRevenue / dayOrders : 0,
        });
      }

      return {
        'period_days': days,
        'total_revenue': totalRevenue,
        'total_orders': totalOrders.toInt(),
        'average_daily_revenue':
            analytics.isNotEmpty ? totalRevenue / analytics.length : 0,
        'average_order_value': totalOrders > 0 ? totalRevenue / totalOrders : 0,
        'daily_breakdown': dailyRevenue,
      };
    } catch (error) {
      throw Exception('Failed to fetch revenue analytics: $error');
    }
  }

  /// Gets popular menu items analytics
  /// [days] - Number of days to analyze
  /// [limit] - Number of items to return
  /// Returns list of popular items with statistics
  Future<List<Map<String, dynamic>>> getPopularItemsAnalytics(
      {int days = 30, int limit = 10}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _client
          .from('order_items')
          .select(
              'menu_item_id, quantity, total_price, menu_items(name, price, image_url, category_id)')
          .gte('created_at', startDate.toIso8601String());

      // Group by menu item
      Map<String, Map<String, dynamic>> itemStats = {};

      for (var item in response) {
        String menuItemId = item['menu_item_id'];
        int quantity = item['quantity'] ?? 0;
        double totalPrice = (item['total_price'] as num?)?.toDouble() ?? 0;

        if (itemStats.containsKey(menuItemId)) {
          itemStats[menuItemId]!['total_quantity'] += quantity;
          itemStats[menuItemId]!['total_revenue'] += totalPrice;
          itemStats[menuItemId]!['order_count'] += 1;
        } else {
          itemStats[menuItemId] = {
            'menu_item_id': menuItemId,
            'menu_item': item['menu_items'],
            'total_quantity': quantity,
            'total_revenue': totalPrice,
            'order_count': 1,
          };
        }
      }

      // Convert to list and calculate additional metrics
      List<Map<String, dynamic>> popularItems = itemStats.values.map((item) {
        int totalQuantity = item['total_quantity'];
        double totalRevenue = item['total_revenue'];
        int orderCount = item['order_count'];

        return {
          ...item,
          'average_quantity_per_order':
              orderCount > 0 ? totalQuantity / orderCount : 0,
          'revenue_per_item':
              totalQuantity > 0 ? totalRevenue / totalQuantity : 0,
        };
      }).toList();

      // Sort by total quantity
      popularItems.sort((a, b) =>
          (b['total_quantity'] as int).compareTo(a['total_quantity'] as int));

      return popularItems.take(limit).toList();
    } catch (error) {
      throw Exception('Failed to fetch popular items analytics: $error');
    }
  }

  /// Gets staff performance analytics
  /// [days] - Number of days to analyze
  /// Returns staff performance data
  Future<List<Map<String, dynamic>>> getStaffPerformance(
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _client
          .from('orders')
          .select(
              'waiter_id, total_amount, status, created_at, user_profiles!waiter_id(full_name, role)')
          .gte('created_at', startDate.toIso8601String())
          .not('waiter_id', 'is', null);

      // Group by waiter
      Map<String, Map<String, dynamic>> staffStats = {};

      for (var order in response) {
        String waiterId = order['waiter_id'];
        double totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0;
        String status = order['status'] ?? 'unknown';

        if (staffStats.containsKey(waiterId)) {
          staffStats[waiterId]!['total_orders'] += 1;
          staffStats[waiterId]!['total_revenue'] += totalAmount;

          if (status == 'delivered') {
            staffStats[waiterId]!['completed_orders'] += 1;
          }
        } else {
          staffStats[waiterId] = {
            'waiter_id': waiterId,
            'waiter_info': order['user_profiles'],
            'total_orders': 1,
            'total_revenue': totalAmount,
            'completed_orders': status == 'delivered' ? 1 : 0,
          };
        }
      }

      // Convert to list and calculate metrics
      List<Map<String, dynamic>> performance = staffStats.values.map((staff) {
        int totalOrders = staff['total_orders'];
        int completedOrders = staff['completed_orders'];
        double totalRevenue = staff['total_revenue'];

        return {
          ...staff,
          'average_order_value':
              totalOrders > 0 ? totalRevenue / totalOrders : 0,
          'completion_rate': totalOrders > 0
              ? (completedOrders / totalOrders * 100).round()
              : 0,
          'revenue_per_day': totalRevenue / days,
        };
      }).toList();

      // Sort by total revenue
      performance.sort((a, b) => (b['total_revenue'] as double)
          .compareTo(a['total_revenue'] as double));

      return performance;
    } catch (error) {
      throw Exception('Failed to fetch staff performance: $error');
    }
  }

  /// Gets peak hours analytics
  /// [days] - Number of days to analyze
  /// Returns hourly order distribution
  Future<Map<String, dynamic>> getPeakHoursAnalytics({int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _client
          .from('orders')
          .select('created_at, total_amount')
          .gte('created_at', startDate.toIso8601String());

      Map<int, Map<String, dynamic>> hourlyStats = {};

      for (var order in response) {
        DateTime orderTime = DateTime.parse(order['created_at']);
        int hour = orderTime.hour;
        double amount = (order['total_amount'] as num?)?.toDouble() ?? 0;

        if (hourlyStats.containsKey(hour)) {
          hourlyStats[hour]!['order_count'] += 1;
          hourlyStats[hour]!['total_revenue'] += amount;
        } else {
          hourlyStats[hour] = {
            'hour': hour,
            'order_count': 1,
            'total_revenue': amount,
          };
        }
      }

      // Calculate averages and format
      List<Map<String, dynamic>> hourlyData = [];
      for (int hour = 0; hour < 24; hour++) {
        if (hourlyStats.containsKey(hour)) {
          int orderCount = hourlyStats[hour]!['order_count'];
          double totalRevenue = hourlyStats[hour]!['total_revenue'];

          hourlyData.add({
            'hour': hour,
            'hour_display': '${hour.toString().padLeft(2, '0')}:00',
            'order_count': orderCount,
            'total_revenue': totalRevenue,
            'average_order_value':
                orderCount > 0 ? totalRevenue / orderCount : 0,
            'daily_average_orders': orderCount / days,
          });
        } else {
          hourlyData.add({
            'hour': hour,
            'hour_display': '${hour.toString().padLeft(2, '0')}:00',
            'order_count': 0,
            'total_revenue': 0.0,
            'average_order_value': 0.0,
            'daily_average_orders': 0.0,
          });
        }
      }

      // Find peak hour
      Map<String, dynamic> peakHour = hourlyData
          .reduce((a, b) => a['order_count'] > b['order_count'] ? a : b);

      return {
        'period_days': days,
        'hourly_breakdown': hourlyData,
        'peak_hour': peakHour['hour'],
        'peak_hour_display': peakHour['hour_display'],
        'peak_hour_orders': peakHour['order_count'],
      };
    } catch (error) {
      throw Exception('Failed to fetch peak hours analytics: $error');
    }
  }

  /// Updates or creates daily analytics entry
  /// [date] - Date to update (defaults to today)
  /// Returns updated analytics data
  Future<Map<String, dynamic>> updateDailyAnalytics({DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final analytics = await generateTodayAnalytics();

      final response = await _client
          .from('daily_analytics')
          .upsert({
            'date': analytics['date'],
            'total_orders': analytics['total_orders'],
            'total_revenue': analytics['total_revenue'],
            'average_order_value': analytics['average_order_value'],
            'peak_hour': analytics['peak_hour'],
            'most_ordered_item_id': analytics['most_ordered_item_id'],
            'total_customers': analytics['total_customers'],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update daily analytics: $error');
    }
  }

  /// Exports analytics data to CSV format
  /// [startDate] - Start date for export
  /// [endDate] - End date for export
  /// Returns CSV string
  Future<String> exportAnalyticsToCSV(
      DateTime startDate, DateTime endDate) async {
    try {
      final analytics = await getAnalyticsRange(startDate, endDate);

      List<String> csvLines = [];
      csvLines.add(
          'Date,Total Orders,Total Revenue,Average Order Value,Peak Hour,Total Customers');

      for (var day in analytics) {
        csvLines.add([
          day['date'],
          day['total_orders'].toString(),
          day['total_revenue'].toString(),
          day['average_order_value'].toString(),
          day['peak_hour'].toString(),
          day['total_customers'].toString(),
        ].join(','));
      }

      return csvLines.join('\n');
    } catch (error) {
      throw Exception('Failed to export analytics to CSV: $error');
    }
  }
}
