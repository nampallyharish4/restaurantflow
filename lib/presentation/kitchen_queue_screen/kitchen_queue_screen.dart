import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_action_bar_widget.dart';
import './widgets/kitchen_header_widget.dart';
import './widgets/order_card_widget.dart';
import './widgets/search_filter_widget.dart';
import './widgets/status_summary_widget.dart';

class KitchenQueueScreen extends StatefulWidget {
  const KitchenQueueScreen({Key? key}) : super(key: key);

  @override
  State<KitchenQueueScreen> createState() => _KitchenQueueScreenState();
}

class _KitchenQueueScreenState extends State<KitchenQueueScreen>
    with TickerProviderStateMixin {
  bool _isRefreshing = false;
  String _searchQuery = '';
  String _currentFilter = 'all';
  late AnimationController _voiceAlertController;
  late Animation<double> _voiceAlertAnimation;

  // Mock data for kitchen orders
  final List<Map<String, dynamic>> _allOrders = [
    {
      "id": 1001,
      "tableNumber": 12,
      "status": "approved",
      "priority": "high",
      "orderTime": DateTime.now().subtract(Duration(minutes: 18)),
      "items": [
        {
          "name": "Grilled Chicken Breast",
          "quantity": 2,
          "customizations": ["Extra spicy", "No onions"]
        },
        {
          "name": "Caesar Salad",
          "quantity": 1,
          "customizations": ["Extra dressing"]
        }
      ],
      "specialInstructions":
          "Customer has nut allergy - please ensure no cross contamination",
      "estimatedTime": 25
    },
    {
      "id": 1002,
      "tableNumber": 8,
      "status": "preparing",
      "priority": "normal",
      "orderTime": DateTime.now().subtract(Duration(minutes: 12)),
      "items": [
        {
          "name": "Margherita Pizza",
          "quantity": 1,
          "customizations": ["Extra cheese", "Thin crust"]
        },
        {"name": "Garlic Bread", "quantity": 2, "customizations": []}
      ],
      "specialInstructions": "",
      "estimatedTime": 20
    },
    {
      "id": 1003,
      "tableNumber": 15,
      "status": "ready",
      "priority": "normal",
      "orderTime": DateTime.now().subtract(Duration(minutes: 8)),
      "items": [
        {
          "name": "Fish and Chips",
          "quantity": 1,
          "customizations": ["Extra tartar sauce"]
        },
        {"name": "Coleslaw", "quantity": 1, "customizations": []}
      ],
      "specialInstructions": "Table requested extra napkins",
      "estimatedTime": 15
    },
    {
      "id": 1004,
      "tableNumber": 3,
      "status": "approved",
      "priority": "high",
      "orderTime": DateTime.now().subtract(Duration(minutes: 22)),
      "items": [
        {
          "name": "Beef Steak",
          "quantity": 1,
          "customizations": ["Medium rare", "Extra sauce"]
        },
        {
          "name": "Mashed Potatoes",
          "quantity": 1,
          "customizations": ["Extra butter"]
        },
        {"name": "Steamed Vegetables", "quantity": 1, "customizations": []}
      ],
      "specialInstructions": "VIP customer - priority service requested",
      "estimatedTime": 30
    },
    {
      "id": 1005,
      "tableNumber": 7,
      "status": "preparing",
      "priority": "normal",
      "orderTime": DateTime.now().subtract(Duration(minutes: 6)),
      "items": [
        {
          "name": "Chicken Curry",
          "quantity": 2,
          "customizations": ["Medium spicy", "Extra rice"]
        },
        {
          "name": "Naan Bread",
          "quantity": 3,
          "customizations": ["Garlic naan"]
        }
      ],
      "specialInstructions": "",
      "estimatedTime": 18
    },
    {
      "id": 1006,
      "tableNumber": 21,
      "status": "ready",
      "priority": "normal",
      "orderTime": DateTime.now().subtract(Duration(minutes: 4)),
      "items": [
        {
          "name": "Pasta Carbonara",
          "quantity": 1,
          "customizations": ["Extra parmesan"]
        }
      ],
      "specialInstructions": "",
      "estimatedTime": 12
    }
  ];

  List<Map<String, dynamic>> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _filteredOrders = List.from(_allOrders);
    _voiceAlertController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _voiceAlertAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _voiceAlertController, curve: Curves.easeInOut),
    );
    _simulateNewOrderAlert();
  }

  @override
  void dispose() {
    _voiceAlertController.dispose();
    super.dispose();
  }

  void _simulateNewOrderAlert() {
    // Simulate new order alert every 30 seconds
    Future.delayed(Duration(seconds: 30), () {
      if (mounted) {
        _triggerVoiceAlert();
        _simulateNewOrderAlert();
      }
    });
  }

  void _triggerVoiceAlert() {
    HapticFeedback.heavyImpact();
    _voiceAlertController.forward().then((_) {
      _voiceAlertController.reverse();
    });

    Fluttertoast.showToast(
      msg: "🔔 New order received!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _allOrders.where((order) {
        // Search filter
        bool matchesSearch = _searchQuery.isEmpty ||
            order['tableNumber'].toString().contains(_searchQuery) ||
            (order['items'] as List).any((item) => (item['name'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()));

        // Status filter
        bool matchesFilter = _currentFilter == 'all' ||
            (_currentFilter == 'priority' && order['priority'] == 'high') ||
            order['status'] == _currentFilter;

        return matchesSearch && matchesFilter;
      }).toList();

      // Sort by priority and time
      _filteredOrders.sort((a, b) {
        if (a['priority'] == 'high' && b['priority'] != 'high') return -1;
        if (b['priority'] == 'high' && a['priority'] != 'high') return 1;
        return (b['orderTime'] as DateTime)
            .compareTo(a['orderTime'] as DateTime);
      });
    });
  }

  Future<void> _refreshQueue() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network refresh
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    Fluttertoast.showToast(
      msg: "Queue refreshed successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _updateOrderStatus(int orderId, String newStatus) {
    setState(() {
      final orderIndex =
          _allOrders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        _allOrders[orderIndex]['status'] = newStatus;
        _filterOrders();
      }
    });

    HapticFeedback.lightImpact();

    String message = '';
    switch (newStatus) {
      case 'preparing':
        message = 'Order #$orderId started preparing';
        break;
      case 'ready':
        message = 'Order #$orderId marked as ready';
        break;
      case 'delivered':
        message = 'Order #$orderId marked as delivered';
        break;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Text(
                    'Order Details',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order['id']}',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'table_restaurant',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Table ${order['tableNumber']}',
                                style: AppTheme.lightTheme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Items with detailed instructions
                    Text(
                      'Items & Instructions:',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ...(order['items'] as List).map((item) {
                      final Map<String, dynamic> itemData =
                          item as Map<String, dynamic>;
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${itemData['quantity']}',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleSmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(
                                    itemData['name'] ?? '',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (itemData['customizations'] != null &&
                                (itemData['customizations'] as List)
                                    .isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(
                                'Customizations:',
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.secondary,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              ...(itemData['customizations'] as List)
                                  .map((customization) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 0.5.h),
                                  child: Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'check_circle',
                                        color: AppTheme
                                            .lightTheme.colorScheme.tertiary,
                                        size: 4.w,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        customization,
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      );
                    }).toList(),

                    if (order['specialInstructions'] != null &&
                        (order['specialInstructions'] as String)
                            .isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.error
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'warning',
                                  color: AppTheme.lightTheme.colorScheme.error,
                                  size: 5.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Special Instructions:',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              order['specialInstructions'],
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNote(int orderId) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController noteController = TextEditingController();
        return AlertDialog(
          title: Text('Add Note to Order #$orderId'),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: 'Enter your note...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Note added to order #$orderId",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
              child: Text('Add Note'),
            ),
          ],
        );
      },
    );
  }

  void _requestHelp(int orderId) {
    Fluttertoast.showToast(
      msg: "Help requested for order #$orderId",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      textColor: Colors.white,
    );
  }

  void _markProblem(int orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Problem'),
        content: Text('Report an issue with Order #$orderId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Problem reported for order #$orderId",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                textColor: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Report'),
          ),
        ],
      ),
    );
  }

  void _callManager() {
    Fluttertoast.showToast(
      msg: "Calling manager...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      textColor: Colors.white,
    );
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController issueController = TextEditingController();
        return AlertDialog(
          title: Text('Report Kitchen Issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Describe the issue you\'re experiencing:'),
              SizedBox(height: 2.h),
              TextField(
                controller: issueController,
                decoration: InputDecoration(
                  hintText: 'Equipment malfunction, ingredient shortage, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Issue reported to management",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                  textColor: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: Text('Report Issue'),
            ),
          ],
        );
      },
    );
  }

  int get _activeOrdersCount => _allOrders
      .where((order) =>
          order['status'] == 'approved' || order['status'] == 'preparing')
      .length;

  double get _averagePreparationTime {
    final preparingOrders =
        _allOrders.where((order) => order['status'] == 'preparing').toList();
    if (preparingOrders.isEmpty) return 0;

    final totalTime = preparingOrders.fold<int>(
        0, (sum, order) => sum + (order['estimatedTime'] as int));
    return totalTime / preparingOrders.length;
  }

  int get _queueDepth =>
      _allOrders.where((order) => order['status'] == 'approved').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Animated voice alert indicator
            AnimatedBuilder(
              animation: _voiceAlertAnimation,
              builder: (context, child) {
                return _voiceAlertAnimation.value > 0
                    ? Container(
                        width: double.infinity,
                        height: 1.h,
                        color:
                            AppTheme.lightTheme.colorScheme.primary.withValues(
                          alpha: _voiceAlertAnimation.value,
                        ),
                      )
                    : SizedBox.shrink();
              },
            ),

            // Kitchen header
            KitchenHeaderWidget(
              stationName: 'Main Kitchen',
              onRefresh: _refreshQueue,
              isRefreshing: _isRefreshing,
            ),

            // Status summary
            StatusSummaryWidget(
              activeOrdersCount: _activeOrdersCount,
              averagePreparationTime: _averagePreparationTime,
              queueDepth: _queueDepth,
            ),

            // Search and filter
            SearchFilterWidget(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _filterOrders();
              },
              onFilterChanged: (filter) {
                setState(() {
                  _currentFilter = filter;
                });
                _filterOrders();
              },
              currentFilter: _currentFilter,
            ),

            // Orders list
            Expanded(
              child: _filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'restaurant_menu',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                            size: 15.w,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No orders in queue',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _searchQuery.isNotEmpty || _currentFilter != 'all'
                                ? 'Try adjusting your filters'
                                : 'New orders will appear here',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshQueue,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return OrderCardWidget(
                            order: order,
                            onStartPreparing: () =>
                                _updateOrderStatus(order['id'], 'preparing'),
                            onMarkReady: () =>
                                _updateOrderStatus(order['id'], 'ready'),
                            onMarkDelivered: () =>
                                _updateOrderStatus(order['id'], 'delivered'),
                            onAddNote: () => _addNote(order['id']),
                            onRequestHelp: () => _requestHelp(order['id']),
                            onMarkProblem: () => _markProblem(order['id']),
                            onLongPress: () => _showOrderDetails(order),
                          );
                        },
                      ),
                    ),
            ),

            // Bottom action bar
            BottomActionBarWidget(
              onCallManager: _callManager,
              onReportIssue: _reportIssue,
            ),
          ],
        ),
      ),
    );
  }
}
