import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/menu_category_tabs.dart';
import './widgets/menu_item_card.dart';
import './widgets/search_bar_widget.dart';
import './widgets/view_cart_button.dart';

class MenuSelectionScreen extends StatefulWidget {
  const MenuSelectionScreen({Key? key}) : super(key: key);

  @override
  State<MenuSelectionScreen> createState() => _MenuSelectionScreenState();
}

class _MenuSelectionScreenState extends State<MenuSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  Map<String, int> _cartItems = {};
  Map<String, bool> _filters = {
    'vegetarian': false,
    'vegan': false,
    'glutenFree': false,
    'spicy': false,
    'recommended': false,
    'available': false,
  };

  final List<String> _categories = [
    'Starters',
    'Main Course',
    'Desserts',
    'Drinks',
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      "id": "1",
      "name": "Crispy Chicken Wings",
      "description":
          "Spicy buffalo wings served with ranch dipping sauce and celery sticks",
      "price": "\$12.99",
      "category": "Starters",
      "image":
          "https://images.pexels.com/photos/60616/fried-chicken-chicken-fried-crunchy-60616.jpeg",
      "isVegetarian": false,
      "isVegan": false,
      "isGlutenFree": false,
      "isSpicy": true,
      "isRecommended": true,
      "isOutOfStock": false,
      "customizations": ["Extra Spicy", "Mild", "BBQ Sauce"],
      "ingredients": "Chicken wings, buffalo sauce, celery, ranch dressing",
      "allergens": ["Dairy", "Gluten"]
    },
    {
      "id": "2",
      "name": "Vegetable Spring Rolls",
      "description":
          "Fresh vegetables wrapped in crispy pastry, served with sweet chili sauce",
      "price": "\$8.99",
      "category": "Starters",
      "image":
          "https://images.pexels.com/photos/4518843/pexels-photo-4518843.jpeg",
      "isVegetarian": true,
      "isVegan": true,
      "isGlutenFree": false,
      "isSpicy": false,
      "isRecommended": false,
      "isOutOfStock": false,
      "customizations": ["Extra Sauce", "No Sauce"],
      "ingredients": "Cabbage, carrots, bean sprouts, spring roll wrapper",
      "allergens": ["Gluten"]
    },
    {
      "id": "3",
      "name": "Grilled Salmon",
      "description":
          "Atlantic salmon grilled to perfection with lemon herb butter and seasonal vegetables",
      "price": "\$24.99",
      "category": "Main Course",
      "image":
          "https://images.pexels.com/photos/1516415/pexels-photo-1516415.jpeg",
      "isVegetarian": false,
      "isVegan": false,
      "isGlutenFree": true,
      "isSpicy": false,
      "isRecommended": true,
      "isOutOfStock": false,
      "customizations": ["Medium", "Well Done", "Extra Lemon"],
      "ingredients":
          "Atlantic salmon, lemon, herbs, butter, seasonal vegetables",
      "allergens": ["Fish", "Dairy"]
    },
    {
      "id": "4",
      "name": "Mushroom Risotto",
      "description":
          "Creamy arborio rice with wild mushrooms, parmesan cheese and truffle oil",
      "price": "\$18.99",
      "category": "Main Course",
      "image":
          "https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg",
      "isVegetarian": true,
      "isVegan": false,
      "isGlutenFree": true,
      "isSpicy": false,
      "isRecommended": false,
      "isOutOfStock": true,
      "customizations": ["Extra Cheese", "No Truffle Oil"],
      "ingredients": "Arborio rice, wild mushrooms, parmesan, truffle oil",
      "allergens": ["Dairy"]
    },
    {
      "id": "5",
      "name": "Chocolate Lava Cake",
      "description":
          "Warm chocolate cake with molten center, served with vanilla ice cream",
      "price": "\$9.99",
      "category": "Desserts",
      "image":
          "https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg",
      "isVegetarian": true,
      "isVegan": false,
      "isGlutenFree": false,
      "isSpicy": false,
      "isRecommended": true,
      "isOutOfStock": false,
      "customizations": ["Extra Ice Cream", "No Ice Cream", "Whipped Cream"],
      "ingredients": "Dark chocolate, flour, eggs, butter, vanilla ice cream",
      "allergens": ["Gluten", "Dairy", "Eggs"]
    },
    {
      "id": "6",
      "name": "Fresh Fruit Tart",
      "description":
          "Buttery pastry shell filled with vanilla custard and topped with seasonal fruits",
      "price": "\$7.99",
      "category": "Desserts",
      "image":
          "https://images.pexels.com/photos/1126359/pexels-photo-1126359.jpeg",
      "isVegetarian": true,
      "isVegan": false,
      "isGlutenFree": false,
      "isSpicy": false,
      "isRecommended": false,
      "isOutOfStock": false,
      "customizations": ["Extra Fruits", "No Custard"],
      "ingredients": "Pastry shell, vanilla custard, seasonal fruits",
      "allergens": ["Gluten", "Dairy", "Eggs"]
    },
    {
      "id": "7",
      "name": "Fresh Orange Juice",
      "description":
          "Freshly squeezed orange juice, no added sugar or preservatives",
      "price": "\$4.99",
      "category": "Drinks",
      "image": "https://images.pexels.com/photos/96974/pexels-photo-96974.jpeg",
      "isVegetarian": true,
      "isVegan": true,
      "isGlutenFree": true,
      "isSpicy": false,
      "isRecommended": false,
      "isOutOfStock": false,
      "customizations": ["Extra Pulp", "No Pulp", "With Ice"],
      "ingredients": "Fresh oranges",
      "allergens": []
    },
    {
      "id": "8",
      "name": "Craft Beer",
      "description": "Local craft beer with hoppy flavor and citrus notes",
      "price": "\$6.99",
      "category": "Drinks",
      "image":
          "https://images.pexels.com/photos/1552630/pexels-photo-1552630.jpeg",
      "isVegetarian": true,
      "isVegan": true,
      "isGlutenFree": false,
      "isSpicy": false,
      "isRecommended": true,
      "isOutOfStock": false,
      "customizations": ["Chilled", "Room Temperature"],
      "ingredients": "Hops, malt, yeast, water",
      "allergens": ["Gluten"]
    }
  ];

  List<Map<String, dynamic>> get _filteredItems {
    List<Map<String, dynamic>> items = _menuItems;

    // Filter by category
    if (_selectedCategoryIndex < _categories.length) {
      final selectedCategory = _categories[_selectedCategoryIndex];
      items =
          items.where((item) => item['category'] == selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        final name = (item['name'] as String).toLowerCase();
        final description = (item['description'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    // Apply filters
    if (_filters['vegetarian'] == true) {
      items = items.where((item) => item['isVegetarian'] == true).toList();
    }
    if (_filters['vegan'] == true) {
      items = items.where((item) => item['isVegan'] == true).toList();
    }
    if (_filters['glutenFree'] == true) {
      items = items.where((item) => item['isGlutenFree'] == true).toList();
    }
    if (_filters['spicy'] == true) {
      items = items.where((item) => item['isSpicy'] == true).toList();
    }
    if (_filters['recommended'] == true) {
      items = items.where((item) => item['isRecommended'] == true).toList();
    }
    if (_filters['available'] == true) {
      items = items.where((item) => item['isOutOfStock'] == false).toList();
    }

    return items;
  }

  int get _totalCartItems {
    return _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

  String get _totalCartPrice {
    double total = 0.0;
    _cartItems.forEach((itemId, quantity) {
      final item = _menuItems.firstWhere((item) => item['id'] == itemId);
      final priceString = item['price'] as String;
      final price = double.parse(priceString.replaceAll('\$', ''));
      total += price * quantity;
    });
    return '\$${total.toStringAsFixed(2)}';
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onQuantityChanged(Map<String, dynamic> item, int quantity) {
    setState(() {
      final itemId = item['id'] as String;
      if (quantity > 0) {
        _cartItems[itemId] = quantity;
      } else {
        _cartItems.remove(itemId);
      }
    });
  }

  void _onFiltersChanged(Map<String, bool> newFilters) {
    setState(() {
      _filters = newFilters;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: _filters,
        onFiltersChanged: _onFiltersChanged,
      ),
    );
  }

  void _viewCart() {
    // Navigate to cart/order review screen
    Navigator.pushNamed(context, '/table-detail-screen');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 2,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add to Order',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Table #12',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/order-history-screen'),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SearchBarWidget(
                controller: _searchController,
                onSearchChanged: _onSearchChanged,
                onFilterTap: _showFilterBottomSheet,
              ),
              MenuCategoryTabs(
                categories: _categories,
                selectedIndex: _selectedCategoryIndex,
                onCategorySelected: _onCategorySelected,
              ),
              Expanded(
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'search_off',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 48,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No items found',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          top: 1.h,
                          bottom: _totalCartItems > 0 ? 12.h : 2.h,
                        ),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return MenuItemCard(
                            item: item,
                            onQuantityChanged: _onQuantityChanged,
                          );
                        },
                      ),
              ),
            ],
          ),
          ViewCartButton(
            itemCount: _totalCartItems,
            totalPrice: _totalCartPrice,
            onTap: _viewCart,
          ),
        ],
      ),
    );
  }
}