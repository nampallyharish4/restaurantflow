import 'dart:convert';
import 'dart:html' as html if (dart.library.html) 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_controls_widget.dart';
import './widgets/order_card_widget.dart';
import './widgets/skeleton_loading_widget.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Filter states
  String _selectedStatus = 'All';
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';

  // Data states
  List<Map<String, dynamic>> _allOrders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;

  // User role simulation
  String _userRole = 'waiter'; // waiter, counter, kitchen

  // Mock data
  final List<Map<String, dynamic>> _mockOrders = [
    {
      "id": "ORD001",
      "timestamp": "2:30 PM",
      "tableNumber": 5,
      "totalAmount": 45.50,
      "status": "completed",
      "customerPhone": "+1 234-567-8901",
      "paymentMethod": "Credit Card",
      "preparationNotes": "Extra spicy, no onions",
      "items": [
        {
          "name": "Chicken Tikka Masala",
          "quantity": 2,
          "price": 18.99,
          "customization": "Extra spicy, medium portion"
        },
        {
          "name": "Garlic Naan",
          "quantity": 3,
          "price": 4.50,
          "customization": "Extra butter"
        },
        {
          "name": "Mango Lassi",
          "quantity": 1,
          "price": 3.99,
          "customization": null
        }
      ]
    },
    {
      "id": "ORD002",
      "timestamp": "1:45 PM",
      "tableNumber": null,
      "totalAmount": 28.75,
      "status": "cancelled",
      "customerPhone": "+1 234-567-8902",
      "paymentMethod": "Cash",
      "preparationNotes": "Customer cancelled due to long wait",
      "items": [
        {
          "name": "Margherita Pizza",
          "quantity": 1,
          "price": 16.99,
          "customization": "Thin crust, extra cheese"
        },
        {
          "name": "Caesar Salad",
          "quantity": 1,
          "price": 11.76,
          "customization": "No croutons, dressing on side"
        }
      ]
    },
    {
      "id": "ORD003",
      "timestamp": "12:15 PM",
      "tableNumber": 12,
      "totalAmount": 67.25,
      "status": "preparing",
      "customerPhone": "+1 234-567-8903",
      "paymentMethod": "Debit Card",
      "preparationNotes": "Birthday celebration - add candle to dessert",
      "items": [
        {
          "name": "Grilled Salmon",
          "quantity": 2,
          "price": 24.99,
          "customization": "Medium rare, lemon on side"
        },
        {
          "name": "Chocolate Cake",
          "quantity": 1,
          "price": 8.99,
          "customization": "Add birthday candle"
        },
        {
          "name": "House Wine",
          "quantity": 2,
          "price": 8.50,
          "customization": "Red wine, room temperature"
        }
      ]
    },
    {
      "id": "ORD004",
      "timestamp": "11:30 AM",
      "tableNumber": 8,
      "totalAmount": 34.20,
      "status": "ready",
      "customerPhone": "+1 234-567-8904",
      "paymentMethod": "Mobile Pay",
      "preparationNotes": "Customer has nut allergy",
      "items": [
        {
          "name": "Vegetable Stir Fry",
          "quantity": 1,
          "price": 15.99,
          "customization": "No nuts, extra vegetables"
        },
        {
          "name": "Spring Rolls",
          "quantity": 4,
          "price": 2.99,
          "customization": "Vegetarian, sweet and sour sauce"
        },
        {
          "name": "Green Tea",
          "quantity": 2,
          "price": 2.50,
          "customization": "Hot, no sugar"
        }
      ]
    },
    {
      "id": "ORD005",
      "timestamp": "10:45 AM",
      "tableNumber": null,
      "totalAmount": 19.99,
      "status": "refunded",
      "customerPhone": "+1 234-567-8905",
      "paymentMethod": "Credit Card",
      "preparationNotes": "Food quality issue - full refund processed",
      "items": [
        {
          "name": "Breakfast Burrito",
          "quantity": 1,
          "price": 12.99,
          "customization": "Scrambled eggs, no cheese"
        },
        {
          "name": "Orange Juice",
          "quantity": 1,
          "price": 3.99,
          "customization": "Fresh squeezed, no pulp"
        },
        {
          "name": "Hash Browns",
          "quantity": 1,
          "price": 3.01,
          "customization": "Extra crispy"
        }
      ]
    },
    {
      "id": "ORD006",
      "timestamp": "9:20 AM",
      "tableNumber": 3,
      "totalAmount": 52.80,
      "status": "completed",
      "customerPhone": "+1 234-567-8906",
      "paymentMethod": "Cash",
      "preparationNotes": "Regular customer - knows the order well",
      "items": [
        {
          "name": "Full English Breakfast",
          "quantity": 2,
          "price": 18.99,
          "customization": "Extra bacon, no black pudding"
        },
        {
          "name": "Coffee",
          "quantity": 2,
          "price": 3.50,
          "customization": "Large, with cream"
        },
        {
          "name": "Toast",
          "quantity": 4,
          "price": 1.99,
          "customization": "Whole wheat, butter on side"
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 1500));

    setState(() {
      _allOrders = List.from(_mockOrders);
      _filteredOrders = List.from(_allOrders);
      _isLoading = false;
    });
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more data
    await Future.delayed(Duration(milliseconds: 1000));

    // Generate additional mock data for pagination
    final additionalOrders = _generateAdditionalOrders();

    setState(() {
      _allOrders.addAll(additionalOrders);
      _applyFilters();
      _isLoadingMore = false;
      _currentPage++;

      // Simulate end of data after 3 pages
      if (_currentPage >= 3) {
        _hasMoreData = false;
      }
    });
  }

  List<Map<String, dynamic>> _generateAdditionalOrders() {
    return List.generate(3, (index) {
      final orderId =
          "ORD${(_currentPage * 10 + index).toString().padLeft(3, '0')}";
      final statuses = ['completed', 'cancelled', 'preparing', 'ready'];
      final status = statuses[index % statuses.length];

      return {
        "id": orderId,
        "timestamp":
            "${9 + index}:${(index * 15).toString().padLeft(2, '0')} AM",
        "tableNumber": index % 2 == 0 ? (index + 1) : null,
        "totalAmount": 25.50 + (index * 5.25),
        "status": status,
        "customerPhone":
            "+1 234-567-89${(10 + index).toString().padLeft(2, '0')}",
        "paymentMethod": ["Cash", "Credit Card", "Debit Card"][index % 3],
        "preparationNotes": "Additional order notes for $orderId",
        "items": [
          {
            "name": "Sample Item ${index + 1}",
            "quantity": index + 1,
            "price": 12.99 + index,
            "customization": index % 2 == 0 ? "Special preparation" : null
          }
        ]
      };
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allOrders);

    // Apply status filter
    if (_selectedStatus != 'All') {
      filtered = filtered
          .where((order) =>
              order['status'].toString().toLowerCase() ==
              _selectedStatus.toLowerCase())
          .toList();
    }

    // Apply date range filter
    if (_selectedDateRange != null) {
      // In a real app, you would parse the timestamp and compare dates
      // For demo purposes, we'll keep all orders
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final query = _searchQuery.toLowerCase();
        return order['id'].toString().toLowerCase().contains(query) ||
            (order['tableNumber']?.toString().toLowerCase().contains(query) ??
                false) ||
            (order['customerPhone']?.toString().toLowerCase().contains(query) ??
                false);
      }).toList();
    }

    setState(() {
      _filteredOrders = filtered;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
    await _loadInitialData();
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _applyFilters();
  }

  void _onDateRangeChanged(DateTimeRange? dateRange) {
    setState(() {
      _selectedDateRange = dateRange;
    });
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  Future<void> _exportData() async {
    try {
      final csvContent = _generateCSVContent();
      await _downloadFile(csvContent, 'order_history.csv');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order history exported successfully'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed. Please try again.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  String _generateCSVContent() {
    final headers = [
      'Order ID',
      'Timestamp',
      'Table',
      'Total Amount',
      'Status',
      'Customer Phone',
      'Payment Method'
    ];
    final csvRows = <String>[];

    csvRows.add(headers.join(','));

    for (final order in _filteredOrders) {
      final row = [
        order['id'],
        order['timestamp'],
        order['tableNumber']?.toString() ?? 'Walk-in',
        '\$${order['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
        order['status'],
        order['customerPhone'] ?? 'N/A',
        order['paymentMethod'] ?? 'N/A',
      ];
      csvRows.add(row.join(','));
    }

    return csvRows.join('\n');
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile platforms, you would use path_provider
      // This is a simplified implementation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved to Downloads folder')),
      );
    }
  }

  void _handleReorder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reorder Confirmation'),
        content:
            Text('Would you like to reorder items from Order #${order['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/menu-selection-screen');
            },
            child: Text('Reorder'),
          ),
        ],
      ),
    );
  }

  void _handleShareReceipt(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt for Order #${order['id']} shared'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _handleAddFeedback(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rate your experience for Order #${order['id']}'),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thank you for your feedback!'),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.tertiary,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: CustomIconWidget(
                      iconName: 'star_border',
                      color: AppTheme.warningLight,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handlePrintReceipt(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing receipt for Order #${order['id']}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _handleRefund(Map<String, dynamic> order) {
    if (_userRole != 'counter') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only counter staff can process refunds'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Process Refund'),
        content: Text(
            'Process refund for Order #${order['id']} (\$${order['totalAmount']?.toStringAsFixed(2)})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Refund processed successfully'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Process Refund'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String tabType) {
    List<Map<String, dynamic>> tabOrders = [];

    switch (tabType) {
      case 'today':
        tabOrders = _filteredOrders;
        break;
      case 'week':
        tabOrders = _filteredOrders;
        break;
      case 'month':
        tabOrders = _filteredOrders;
        break;
    }

    if (_isLoading) {
      return SkeletonLoadingWidget();
    }

    if (tabOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'receipt_long',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No orders found',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your filters or check back later',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: tabOrders.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tabOrders.length) {
            return Container(
              padding: EdgeInsets.all(4.w),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            );
          }

          final order = tabOrders[index];
          return OrderCardWidget(
            order: order,
            userRole: _userRole,
            onReorder: () => _handleReorder(order),
            onShareReceipt: () => _handleShareReceipt(order),
            onAddFeedback: () => _handleAddFeedback(order),
            onPrintReceipt: () => _handlePrintReceipt(order),
            onRefund: () => _handleRefund(order),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Order History',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            onSelected: (value) {
              switch (value) {
                case 'waiter':
                case 'counter':
                case 'kitchen':
                  setState(() {
                    _userRole = value;
                  });
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'waiter',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'person',
                      color: _userRole == 'waiter'
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Waiter View'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'counter',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'point_of_sale',
                      color: _userRole == 'counter'
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Counter View'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'kitchen',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'restaurant',
                      color: _userRole == 'kitchen'
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Kitchen View'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.lightTheme.colorScheme.primary,
          unselectedLabelColor:
              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          indicatorColor: AppTheme.lightTheme.colorScheme.primary,
          tabs: [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
      body: Column(
        children: [
          FilterControlsWidget(
            selectedStatus: _selectedStatus,
            selectedDateRange: _selectedDateRange,
            searchQuery: _searchQuery,
            onStatusChanged: _onStatusChanged,
            onDateRangeChanged: _onDateRangeChanged,
            onSearchChanged: _onSearchChanged,
            onExport: _exportData,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('today'),
                _buildTabContent('week'),
                _buildTabContent('month'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
