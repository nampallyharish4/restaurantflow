import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/order_detail_bottom_sheet.dart';
import './widgets/pending_order_card_widget.dart';
import './widgets/summary_card_widget.dart';

class CounterDashboardScreen extends StatefulWidget {
  const CounterDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CounterDashboardScreen> createState() => _CounterDashboardScreenState();
}

class _CounterDashboardScreenState extends State<CounterDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  bool _isRefreshing = false;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];

  // Mock data for orders
  final List<Map<String, dynamic>> _mockOrders = [
    {
      "id": 1001,
      "tableNumber": 5,
      "waiterName": "Sarah Johnson",
      "status": "pending",
      "total": "\$45.50",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 8)),
      "items": [
        {
          "name": "Margherita Pizza",
          "quantity": 1,
          "price": "\$18.50",
          "customizations": ["Extra cheese", "Thin crust"]
        },
        {
          "name": "Caesar Salad",
          "quantity": 2,
          "price": "\$24.00",
          "customizations": ["No croutons"]
        },
        {
          "name": "Garlic Bread",
          "quantity": 1,
          "price": "\$3.00",
          "customizations": []
        }
      ]
    },
    {
      "id": 1002,
      "tableNumber": 12,
      "waiterName": "Mike Chen",
      "status": "pending",
      "total": "\$78.25",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 12)),
      "items": [
        {
          "name": "Grilled Salmon",
          "quantity": 2,
          "price": "\$56.00",
          "customizations": ["Medium rare", "Lemon sauce"]
        },
        {
          "name": "Chocolate Cake",
          "quantity": 1,
          "price": "\$12.25",
          "customizations": ["Extra whipped cream"]
        },
        {
          "name": "Red Wine",
          "quantity": 1,
          "price": "\$10.00",
          "customizations": []
        }
      ]
    },
    {
      "id": 1003,
      "tableNumber": 8,
      "waiterName": "Emma Davis",
      "status": "approved",
      "total": "\$32.75",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 18)),
      "items": [
        {
          "name": "Chicken Burger",
          "quantity": 1,
          "price": "\$15.50",
          "customizations": ["No pickles", "Extra sauce"]
        },
        {
          "name": "French Fries",
          "quantity": 1,
          "price": "\$8.25",
          "customizations": ["Large size"]
        },
        {
          "name": "Coca Cola",
          "quantity": 2,
          "price": "\$9.00",
          "customizations": ["With ice"]
        }
      ]
    },
    {
      "id": 1004,
      "tableNumber": 3,
      "waiterName": "James Wilson",
      "status": "pending",
      "total": "\$95.00",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 22)),
      "items": [
        {
          "name": "Lobster Thermidor",
          "quantity": 1,
          "price": "\$65.00",
          "customizations": ["Extra butter"]
        },
        {
          "name": "Asparagus",
          "quantity": 1,
          "price": "\$15.00",
          "customizations": ["Grilled"]
        },
        {
          "name": "Champagne",
          "quantity": 1,
          "price": "\$15.00",
          "customizations": []
        }
      ]
    },
    {
      "id": 1005,
      "tableNumber": 15,
      "waiterName": "Lisa Anderson",
      "status": "rejected",
      "total": "\$28.50",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 35)),
      "items": [
        {
          "name": "Vegetable Pasta",
          "quantity": 1,
          "price": "\$16.50",
          "customizations": ["Gluten-free"]
        },
        {
          "name": "Green Salad",
          "quantity": 1,
          "price": "\$12.00",
          "customizations": ["Balsamic dressing"]
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _orders = List.from(_mockOrders);
    _applyFilter();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filteredOrders = List.from(_orders);
      } else {
        _filteredOrders = _orders
            .where((order) =>
                (order['status'] as String).toLowerCase() ==
                _selectedFilter.toLowerCase())
            .toList();
      }

      // Apply search filter if search text exists
      if (_searchController.text.isNotEmpty) {
        _filteredOrders = _filteredOrders.where((order) {
          final searchText = _searchController.text.toLowerCase();
          final tableNumber = order['tableNumber'].toString();
          final items = (order['items'] as List)
              .map((item) => (item['name'] as String).toLowerCase())
              .join(' ');
          return tableNumber.contains(searchText) || items.contains(searchText);
        }).toList();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Add a new mock order to simulate real-time updates
    final newOrder = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "tableNumber": (DateTime.now().millisecond % 20) + 1,
      "waiterName": "New Waiter",
      "status": "pending",
      "total":
          "\$${(25 + (DateTime.now().millisecond % 50)).toStringAsFixed(2)}",
      "timestamp": DateTime.now(),
      "items": [
        {
          "name": "Fresh Order Item",
          "quantity": 1,
          "price": "\$15.00",
          "customizations": ["Just added"]
        }
      ]
    };

    setState(() {
      _orders.insert(0, newOrder);
      _isRefreshing = false;
    });

    _applyFilter();

    Fluttertoast.showToast(
      msg: "Orders updated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _approveOrder(Map<String, dynamic> order) {
    HapticFeedback.mediumImpact();

    setState(() {
      final index = _orders.indexWhere((o) => o['id'] == order['id']);
      if (index != -1) {
        _orders[index]['status'] = 'approved';
      }
    });

    _applyFilter();

    Fluttertoast.showToast(
      msg: "Order #${order['id']} approved and sent to kitchen",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
    );
  }

  void _rejectOrder(Map<String, dynamic> order) {
    HapticFeedback.mediumImpact();

    setState(() {
      final index = _orders.indexWhere((o) => o['id'] == order['id']);
      if (index != -1) {
        _orders[index]['status'] = 'rejected';
      }
    });

    _applyFilter();

    Fluttertoast.showToast(
      msg: "Order #${order['id']} rejected",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailBottomSheet(
        order: order,
        onApprove: () => _approveOrder(order),
        onReject: () => _rejectOrder(order),
        onAddNote: () {
          Fluttertoast.showToast(
            msg: "Add note feature coming soon",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
        onContactWaiter: () {
          Fluttertoast.showToast(
            msg: "Contacting ${order['waiterName']}...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
        onModifyItems: () {
          Fluttertoast.showToast(
            msg: "Modify items feature coming soon",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
      ),
    );
  }

  void _showLongPressActions(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'note_add',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Add Note'),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Add note feature coming soon",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'call',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Contact Waiter'),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Contacting ${order['waiterName']}...",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Modify Items'),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Modify items feature coming soon",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  int _getOrderCountByStatus(String status) {
    if (status == 'All') return _orders.length;
    return _orders
        .where((order) =>
            (order['status'] as String).toLowerCase() == status.toLowerCase())
        .length;
  }

  double _getTotalRevenue() {
    return _orders
        .where((order) => (order['status'] as String) == 'approved')
        .map((order) =>
            double.parse((order['total'] as String).replaceAll('\$', '')))
        .fold(0.0, (sum, amount) => sum + amount);
  }

  double _getAverageOrderValue() {
    final approvedOrders = _orders
        .where((order) => (order['status'] as String) == 'approved')
        .toList();
    if (approvedOrders.isEmpty) return 0.0;

    final totalRevenue = _getTotalRevenue();
    return totalRevenue / approvedOrders.length;
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _getOrderCountByStatus('Pending');
    final totalRevenue = _getTotalRevenue();
    final averageOrderValue = _getAverageOrderValue();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow
                        .withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Counter Dashboard',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Manage orders and approvals',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: 'notifications',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: AppTheme.lightTheme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Orders'),
                  Tab(text: 'Bills'),
                  Tab(text: 'Analytics'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Dashboard Tab
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Cards
                          Row(
                            children: [
                              SummaryCardWidget(
                                title: 'Total Orders',
                                value: '${_orders.length}',
                                subtitle: 'Today',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                iconName: 'receipt_long',
                              ),
                              SizedBox(width: 4.w),
                              SummaryCardWidget(
                                title: 'Pending Approvals',
                                value: '$pendingCount',
                                subtitle: 'Requires action',
                                color: const Color(0xFFF18701),
                                iconName: 'pending_actions',
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              SummaryCardWidget(
                                title: 'Revenue',
                                value: '\$${totalRevenue.toStringAsFixed(2)}',
                                subtitle: 'Today\'s total',
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                                iconName: 'attach_money',
                              ),
                              SizedBox(width: 4.w),
                              SummaryCardWidget(
                                title: 'Avg Order Value',
                                value:
                                    '\$${averageOrderValue.toStringAsFixed(2)}',
                                subtitle: 'Per order',
                                color: const Color(0xFF2E86AB),
                                iconName: 'trending_up',
                              ),
                            ],
                          ),

                          SizedBox(height: 4.h),

                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => _applyFilter(),
                              decoration: InputDecoration(
                                hintText: 'Search by table number or items...',
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: CustomIconWidget(
                                    iconName: 'search',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 2.h),
                              ),
                            ),
                          ),

                          SizedBox(height: 3.h),

                          // Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChipWidget(
                                  label: 'All',
                                  isSelected: _selectedFilter == 'All',
                                  count: _getOrderCountByStatus('All'),
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'All';
                                    });
                                    _applyFilter();
                                  },
                                ),
                                FilterChipWidget(
                                  label: 'Pending',
                                  isSelected: _selectedFilter == 'Pending',
                                  count: _getOrderCountByStatus('Pending'),
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Pending';
                                    });
                                    _applyFilter();
                                  },
                                ),
                                FilterChipWidget(
                                  label: 'Approved',
                                  isSelected: _selectedFilter == 'Approved',
                                  count: _getOrderCountByStatus('Approved'),
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Approved';
                                    });
                                    _applyFilter();
                                  },
                                ),
                                FilterChipWidget(
                                  label: 'Rejected',
                                  isSelected: _selectedFilter == 'Rejected',
                                  count: _getOrderCountByStatus('Rejected'),
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Rejected';
                                    });
                                    _applyFilter();
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 3.h),

                          // Orders List
                          Text(
                            'Orders (${_filteredOrders.length})',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),

                          _filteredOrders.isEmpty
                              ? Container(
                                  height: 30.h,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'inbox',
                                          color: AppTheme
                                              .lightTheme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                          size: 48,
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'No orders found',
                                          style: AppTheme
                                              .lightTheme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        Text(
                                          'Pull to refresh or try a different filter',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurface
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _filteredOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = _filteredOrders[index];
                                    return PendingOrderCardWidget(
                                      order: order,
                                      onApprove: () => _approveOrder(order),
                                      onReject: () => _rejectOrder(order),
                                      onTap: () => _showOrderDetails(order),
                                      onLongPress: () =>
                                          _showLongPressActions(order),
                                    );
                                  },
                                ),

                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ),

                  // Orders Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'restaurant_menu',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Orders Management',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Coming soon...',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bills Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'receipt',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Bills Management',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Coming soon...',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Analytics Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'analytics',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Analytics Dashboard',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Coming soon...',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
