import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_model.dart';
import './supabase_service.dart';

/// Service for managing restaurant menu items and categories
class MenuService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Gets all menu categories
  /// Returns list of category data
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  /// Gets all menu items with optional category filter
  /// [categoryId] - Optional category ID to filter by
  /// [isAvailable] - Filter by availability (defaults to true)
  /// Returns list of MenuItemModel
  Future<List<MenuItemModel>> getMenuItems({
    String? categoryId,
    bool isAvailable = true,
  }) async {
    try {
      var query = _client
          .from('menu_items')
          .select('*, categories(name, display_name)')
          .eq('is_available', isAvailable);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query.order('name', ascending: true);

      return response
          .map<MenuItemModel>((item) => MenuItemModel.fromMap(item))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch menu items: $error');
    }
  }

  /// Gets menu items by category type
  /// [categoryType] - Type of category (starters, main_course, desserts, drinks, specials)
  /// Returns list of MenuItemModel
  Future<List<MenuItemModel>> getMenuItemsByCategory(
      String categoryType) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('*, categories!inner(name, display_name, category_type)')
          .eq('categories.category_type', categoryType)
          .eq('is_available', true)
          .order('name', ascending: true);

      return response
          .map<MenuItemModel>((item) => MenuItemModel.fromMap(item))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch menu items by category: $error');
    }
  }

  /// Gets a single menu item by ID
  /// [menuItemId] - ID of the menu item
  /// Returns MenuItemModel or null if not found
  Future<MenuItemModel?> getMenuItemById(String menuItemId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('*, categories(name, display_name)')
          .eq('id', menuItemId)
          .maybeSingle();

      return response != null ? MenuItemModel.fromMap(response) : null;
    } catch (error) {
      throw Exception('Failed to fetch menu item: $error');
    }
  }

  /// Searches menu items by name or description
  /// [searchTerm] - Term to search for
  /// [categoryId] - Optional category filter
  /// Returns list of MenuItemModel
  Future<List<MenuItemModel>> searchMenuItems(String searchTerm,
      {String? categoryId}) async {
    try {
      var query = _client
          .from('menu_items')
          .select('*, categories(name, display_name)')
          .eq('is_available', true)
          .or('name.ilike.%$searchTerm%,description.ilike.%$searchTerm%');

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query.order('name', ascending: true);

      return response
          .map<MenuItemModel>((item) => MenuItemModel.fromMap(item))
          .toList();
    } catch (error) {
      throw Exception('Failed to search menu items: $error');
    }
  }

  /// Filters menu items by dietary preferences
  /// [isVegetarian] - Filter vegetarian items
  /// [isVegan] - Filter vegan items
  /// [isSpicy] - Filter spicy items
  /// [categoryId] - Optional category filter
  /// Returns list of MenuItemModel
  Future<List<MenuItemModel>> filterMenuItems({
    bool? isVegetarian,
    bool? isVegan,
    bool? isSpicy,
    String? categoryId,
  }) async {
    try {
      var query = _client
          .from('menu_items')
          .select('*, categories(name, display_name)')
          .eq('is_available', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (isVegetarian != null) {
        query = query.eq('is_vegetarian', isVegetarian);
      }
      if (isVegan != null) {
        query = query.eq('is_vegan', isVegan);
      }
      if (isSpicy != null) {
        query = query.eq('is_spicy', isSpicy);
      }

      final response = await query.order('name', ascending: true);

      return response
          .map<MenuItemModel>((item) => MenuItemModel.fromMap(item))
          .toList();
    } catch (error) {
      throw Exception('Failed to filter menu items: $error');
    }
  }

  /// Creates a new menu item (admin only)
  /// [name] - Name of the menu item
  /// [description] - Description of the item
  /// [price] - Price of the item
  /// [categoryId] - Category ID
  /// [imageUrl] - Optional image URL
  /// [isVegetarian] - Is vegetarian
  /// [isVegan] - Is vegan
  /// [isSpicy] - Is spicy
  /// [preparationTime] - Preparation time in minutes
  /// [allergens] - List of allergens
  /// Returns created MenuItemModel
  Future<MenuItemModel> createMenuItem({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    String? imageUrl,
    bool isVegetarian = false,
    bool isVegan = false,
    bool isSpicy = false,
    int preparationTime = 15,
    List<String> allergens = const [],
  }) async {
    try {
      final response = await _client
          .from('menu_items')
          .insert({
            'name': name,
            'description': description,
            'price': price,
            'category_id': categoryId,
            'image_url': imageUrl,
            'is_vegetarian': isVegetarian,
            'is_vegan': isVegan,
            'is_spicy': isSpicy,
            'preparation_time': preparationTime,
            'allergens': allergens,
          })
          .select('*, categories(name, display_name)')
          .single();

      return MenuItemModel.fromMap(response);
    } catch (error) {
      throw Exception('Failed to create menu item: $error');
    }
  }

  /// Updates a menu item (admin only)
  /// [menuItemId] - ID of the menu item
  /// [updates] - Map of fields to update
  /// Returns updated MenuItemModel
  Future<MenuItemModel> updateMenuItem(
      String menuItemId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('menu_items')
          .update(updates)
          .eq('id', menuItemId)
          .select('*, categories(name, display_name)')
          .single();

      return MenuItemModel.fromMap(response);
    } catch (error) {
      throw Exception('Failed to update menu item: $error');
    }
  }

  /// Toggles menu item availability
  /// [menuItemId] - ID of the menu item
  /// [isAvailable] - New availability status
  /// Returns updated MenuItemModel
  Future<MenuItemModel> toggleMenuItemAvailability(
      String menuItemId, bool isAvailable) async {
    try {
      return await updateMenuItem(menuItemId, {'is_available': isAvailable});
    } catch (error) {
      throw Exception('Failed to toggle menu item availability: $error');
    }
  }

  /// Deletes a menu item (admin only)
  /// [menuItemId] - ID of the menu item
  /// Returns true if successful
  Future<bool> deleteMenuItem(String menuItemId) async {
    try {
      await _client.from('menu_items').delete().eq('id', menuItemId);

      return true;
    } catch (error) {
      throw Exception('Failed to delete menu item: $error');
    }
  }

  /// Creates a new category (admin only)
  /// [name] - Category name
  /// [displayName] - Display name for the category
  /// [categoryType] - Type of category
  /// [description] - Optional description
  /// [sortOrder] - Sort order
  /// Returns created category data
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String displayName,
    required String categoryType,
    String? description,
    int sortOrder = 0,
  }) async {
    try {
      final response = await _client
          .from('categories')
          .insert({
            'name': name,
            'display_name': displayName,
            'category_type': categoryType,
            'description': description,
            'sort_order': sortOrder,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create category: $error');
    }
  }

  /// Updates a category (admin only)
  /// [categoryId] - ID of the category
  /// [updates] - Map of fields to update
  /// Returns updated category data
  Future<Map<String, dynamic>> updateCategory(
      String categoryId, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('categories')
          .update(updates)
          .eq('id', categoryId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update category: $error');
    }
  }

  /// Gets popular menu items based on order frequency
  /// [limit] - Number of items to return
  /// [days] - Number of days to look back
  /// Returns list of MenuItemModel with order counts
  Future<List<Map<String, dynamic>>> getPopularMenuItems(
      {int limit = 10, int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _client
          .from('order_items')
          .select('menu_item_id, quantity, menu_items(name, price, image_url)')
          .gte('created_at', startDate.toIso8601String())
          .order('quantity', ascending: false)
          .limit(limit);

      // Group by menu item and sum quantities
      Map<String, Map<String, dynamic>> itemStats = {};

      for (var item in response) {
        String menuItemId = item['menu_item_id'];
        int quantity = item['quantity'] ?? 0;

        if (itemStats.containsKey(menuItemId)) {
          itemStats[menuItemId]!['total_quantity'] += quantity;
          itemStats[menuItemId]!['order_count'] += 1;
        } else {
          itemStats[menuItemId] = {
            'menu_item_id': menuItemId,
            'menu_item': item['menu_items'],
            'total_quantity': quantity,
            'order_count': 1,
          };
        }
      }

      // Convert to list and sort by total quantity
      List<Map<String, dynamic>> popularItems = itemStats.values.toList();
      popularItems.sort((a, b) =>
          (b['total_quantity'] as int).compareTo(a['total_quantity'] as int));

      return popularItems.take(limit).toList();
    } catch (error) {
      throw Exception('Failed to fetch popular menu items: $error');
    }
  }

  /// Gets menu item statistics
  /// [menuItemId] - ID of the menu item
  /// [days] - Number of days to analyze
  /// Returns statistics map
  Future<Map<String, dynamic>> getMenuItemStatistics(String menuItemId,
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _client
          .from('order_items')
          .select('quantity, total_price, created_at')
          .eq('menu_item_id', menuItemId)
          .gte('created_at', startDate.toIso8601String());

      int totalOrders = response.length;
      int totalQuantity = 0;
      double totalRevenue = 0;

      for (var item in response) {
        totalQuantity += (item['quantity'] as int? ?? 0);
        totalRevenue += (item['total_price'] as num?)?.toDouble() ?? 0;
      }

      return {
        'total_orders': totalOrders,
        'total_quantity': totalQuantity,
        'total_revenue': totalRevenue,
        'average_quantity_per_order':
            totalOrders > 0 ? totalQuantity / totalOrders : 0,
        'days_analyzed': days,
      };
    } catch (error) {
      throw Exception('Failed to fetch menu item statistics: $error');
    }
  }
}
