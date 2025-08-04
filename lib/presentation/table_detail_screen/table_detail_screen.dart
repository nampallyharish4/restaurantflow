import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_action_bar.dart';
import './widgets/order_history_item.dart';
import './widgets/order_item_card.dart';
import './widgets/order_summary_card.dart';
import './widgets/table_info_card.dart';

class TableDetailScreen extends StatefulWidget {
  const TableDetailScreen({Key? key}) : super(key: key);

  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock data for table information
  final Map<String, dynamic> _tableData = {
    "number": 12,
    "partySize": 4,
    "server": "Sarah Johnson",
    "startTime": DateTime.now().subtract(const Duration(hours: 1, minutes: 23)),
  };

  // Mock data for current order items
  final List<Map<String, dynamic>> _currentOrderItems = [
    {
      "id": 1,
      "name": "Margherita Pizza",
      "quantity": 2,
      "customizations": ["Extra Cheese", "Thin Crust"],
      "price": "\$28.00",
      "status": "Preparing",
      "note": "Please make it extra crispy",
    },
    {
      "id": 2,
      "name": "Caesar Salad",
      "quantity": 1,
      "customizations": ["No Croutons", "Extra Dressing"],
      "price": "\$14.50",
      "status": "Ready",
      "note": "",
    },
    {
      "id": 3,
      "name": "Grilled Chicken Breast",
      "quantity": 1,
      "customizations": ["Medium Well", "Side of Vegetables"],
      "price": "\$22.00",
      "status": "Ordered",
      "note": "Customer has nut allergy",
    },
    {
      "id": 4,
      "name": "Chocolate Lava Cake",
      "quantity": 2,
      "customizations": ["Vanilla Ice Cream"],
      "price": "\$16.00",
      "status": "Ordered",
      "note": "",
    },
  ];

  // Mock data for order summary
  final Map<String, dynamic> _orderSummary = {
    "subtotal": "\$80.50",
    "taxRate": "8.5",
    "tax": "\$6.84",
    "total": "\$87.34",
  };

  // Mock data for order history
  final List<Map<String, dynamic>> _orderHistory = [
    {
      "orderId": "ORD001",
      "orderTime":
          DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      "completedTime": DateTime.now().subtract(const Duration(hours: 2)),
      "status": "Completed",
      "items": [
        {"name": "Appetizer Platter", "quantity": 1, "price": "\$18.00"},
        {"name": "Iced Tea", "quantity": 4, "price": "\$12.00"},
      ],
      "total": "\$30.00",
    },
    {
      "orderId": "ORD002",
      "orderTime":
          DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      "completedTime":
          DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      "status": "Completed",
      "items": [
        {"name": "Garlic Bread", "quantity": 2, "price": "\$8.00"},
        {"name": "Soft Drinks", "quantity": 2, "price": "\$6.00"},
      ],
      "total": "\$14.00",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshOrderStatus,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: Column(
          children: [
            TableInfoCard(tableData: _tableData),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCurrentOrderTab(),
                  _buildOrderHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        onCallWaiter: _callWaiter,
        onRequestCheck: _requestCheck,
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToMenuSelection,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                'Add Items',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 2,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      title: Text(
        'Table ${_tableData['number']}',
        style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showQuickReorderDialog,
          icon: CustomIconWidget(
            iconName: 'refresh',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: _showTableOptions,
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor:
            AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
        labelStyle: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle:
            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Current Order'),
          Tab(text: 'Order History'),
        ],
      ),
    );
  }

  Widget _buildCurrentOrderTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 1.h),
          if (_currentOrderItems.isEmpty)
            _buildEmptyOrderState()
          else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentOrderItems.length,
              itemBuilder: (context, index) {
                final orderItem = _currentOrderItems[index];
                return OrderItemCard(
                  orderItem: orderItem,
                  onEdit: () => _editOrderItem(orderItem),
                  onAddNote: () => _addNoteToItem(orderItem),
                  onCancel: () => _cancelOrderItem(orderItem),
                  onLongPress: () => _showItemDetails(orderItem),
                );
              },
            ),
            SizedBox(height: 2.h),
            OrderSummaryCard(
              orderSummary: _orderSummary,
              onGenerateBill: _generateBill,
            ),
          ],
          SizedBox(height: 10.h), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildOrderHistoryTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 1.h),
          if (_orderHistory.isEmpty)
            _buildEmptyHistoryState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orderHistory.length,
              itemBuilder: (context, index) {
                return OrderHistoryItem(
                  historyItem: _orderHistory[index],
                );
              },
            ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildEmptyOrderState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'restaurant_menu',
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.3),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No items ordered yet',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap "Add Items" to start ordering',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.3),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No order history',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Previous orders will appear here',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _refreshOrderStatus() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    Fluttertoast.showToast(
      msg: "Order status updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _navigateToMenuSelection() {
    Navigator.pushNamed(context, '/menu-selection-screen');
  }

  void _editOrderItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit ${item['name']}',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current quantity: ${item['quantity']}',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showQuantityDialog(item);
                  },
                  child: const Text('Change Quantity'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCustomizationDialog(item);
                  },
                  child: const Text('Modify'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(Map<String, dynamic> item) {
    int currentQuantity = item['quantity'] as int;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Quantity'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: currentQuantity > 1
                    ? () {
                        setDialogState(() => currentQuantity--);
                      }
                    : null,
                icon: CustomIconWidget(
                  iconName: 'remove',
                  color: currentQuantity > 1
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.grey,
                  size: 24,
                ),
              ),
              Text(
                '$currentQuantity',
                style: AppTheme.lightTheme.textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () {
                  setDialogState(() => currentQuantity++);
                },
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item['quantity'] = currentQuantity;
              });
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "Quantity updated");
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showCustomizationDialog(Map<String, dynamic> item) {
    Navigator.pop(context);
    Fluttertoast.showToast(msg: "Customization options coming soon");
  }

  void _addNoteToItem(Map<String, dynamic> item) {
    final TextEditingController noteController = TextEditingController(
      text: item['note'] as String? ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Note to ${item['name']}'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter special instructions...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item['note'] = noteController.text;
              });
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "Note added successfully");
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _cancelOrderItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Item'),
        content: Text('Are you sure you want to cancel ${item['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentOrderItems
                    .removeWhere((orderItem) => orderItem['id'] == item['id']);
              });
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "Item cancelled");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantity: ${item['quantity']}'),
            SizedBox(height: 1.h),
            Text('Price: ${item['price']}'),
            SizedBox(height: 1.h),
            Text('Status: ${item['status']}'),
            if ((item['customizations'] as List).isNotEmpty) ...[
              SizedBox(height: 1.h),
              const Text('Customizations:'),
              ...(item['customizations'] as List).map((custom) => Text(
                  '• $custom',
                  style: AppTheme.lightTheme.textTheme.bodySmall)),
            ],
            if ((item['note'] as String).isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text('Note: ${item['note']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _generateBill() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Bill'),
        content: const Text(
            'Are you sure you want to generate the bill for this table?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "Bill generated successfully");
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _callWaiter() {
    Fluttertoast.showToast(
      msg: "Waiter has been notified",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _requestCheck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Check'),
        content:
            const Text('Would you like to request the check for this table?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "Check requested");
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showQuickReorderDialog() {
    final List<Map<String, dynamic>> popularItems = [
      {"name": "Margherita Pizza", "price": "\$14.00"},
      {"name": "Caesar Salad", "price": "\$12.50"},
      {"name": "Garlic Bread", "price": "\$6.00"},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Reorder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: popularItems
              .map((item) => ListTile(
                    title: Text(item['name'] as String),
                    trailing: Text(item['price'] as String),
                    onTap: () {
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                          msg: "${item['name']} added to order");
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTableOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Share Order'),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(msg: "Sharing order details");
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'print',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Print Order'),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(msg: "Printing order");
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'feedback',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Leave Feedback'),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(msg: "Feedback form coming soon");
              },
            ),
          ],
        ),
      ),
    );
  }
}
