import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrderCardWidget extends StatefulWidget {
  final Map<String, dynamic> order;
  final String userRole;
  final VoidCallback? onReorder;
  final VoidCallback? onShareReceipt;
  final VoidCallback? onAddFeedback;
  final VoidCallback? onPrintReceipt;
  final VoidCallback? onRefund;

  const OrderCardWidget({
    Key? key,
    required this.order,
    required this.userRole,
    this.onReorder,
    this.onShareReceipt,
    this.onAddFeedback,
    this.onPrintReceipt,
    this.onRefund,
  }) : super(key: key);

  @override
  State<OrderCardWidget> createState() => _OrderCardWidgetState();
}

class _OrderCardWidgetState extends State<OrderCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'cancelled':
        return AppTheme.lightTheme.colorScheme.error;
      case 'refunded':
        return AppTheme.warningLight;
      case 'preparing':
        return AppTheme.warningLight;
      case 'ready':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showOrderActions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Order Actions',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            if (widget.userRole == 'waiter' ||
                widget.userRole == 'counter') ...[
              _buildActionTile(
                icon: 'receipt',
                title: 'Print Receipt',
                onTap: () {
                  Navigator.pop(context);
                  widget.onPrintReceipt?.call();
                },
              ),
              _buildActionTile(
                icon: 'person',
                title: 'Customer Details',
                onTap: () {
                  Navigator.pop(context);
                  _showCustomerDetails();
                },
              ),
            ],
            if (widget.userRole == 'counter' &&
                widget.order['status'] == 'completed') ...[
              _buildActionTile(
                icon: 'money_off',
                title: 'Process Refund',
                onTap: () {
                  Navigator.pop(context);
                  widget.onRefund?.call();
                },
              ),
            ],
            if (widget.userRole == 'kitchen') ...[
              _buildActionTile(
                icon: 'note',
                title: 'View Preparation Notes',
                onTap: () {
                  Navigator.pop(context);
                  _showPreparationNotes();
                },
              ),
            ],
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showCustomerDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Customer Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${widget.order['customerPhone'] ?? 'N/A'}'),
            SizedBox(height: 1.h),
            Text('Table: ${widget.order['tableNumber'] ?? 'Walk-in'}'),
            SizedBox(height: 1.h),
            Text('Payment: ${widget.order['paymentMethod'] ?? 'Cash'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPreparationNotes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preparation Notes'),
        content: Text(
          widget.order['preparationNotes'] ?? 'No special instructions',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = (widget.order['items'] as List?) ?? [];
    final status = widget.order['status'] ?? 'pending';
    final isCompleted = status.toLowerCase() == 'completed';

    return Dismissible(
      key: Key(widget.order['id'].toString()),
      direction:
          isCompleted ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'refresh',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Reorder',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        widget.onReorder?.call();
      },
      child: GestureDetector(
        onTap: _toggleExpansion,
        onLongPress: _showOrderActions,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '#${widget.order['id']}',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'access_time',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                widget.order['timestamp'] ?? '12:30 PM',
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                              SizedBox(width: 4.w),
                              if (widget.order['tableNumber'] != null) ...[
                                CustomIconWidget(
                                  iconName: 'table_restaurant',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Table ${widget.order['tableNumber']}',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ] else ...[
                                CustomIconWidget(
                                  iconName: 'directions_walk',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Walk-in',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${widget.order['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        CustomIconWidget(
                          iconName: _isExpanded ? 'expand_less' : 'expand_more',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        height: 1,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Order Items',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      ...items
                          .map<Widget>((item) => Padding(
                                padding: EdgeInsets.only(bottom: 1.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 1.w,
                                      height: 4.h,
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item['quantity']}x ${item['name']}',
                                            style: AppTheme
                                                .lightTheme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (item['customization'] !=
                                              null) ...[
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              item['customization'],
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                color: AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\$${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      if (isCompleted) ...[
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: 'refresh',
                              label: 'Reorder',
                              onTap: widget.onReorder,
                            ),
                            _buildActionButton(
                              icon: 'share',
                              label: 'Share',
                              onTap: widget.onShareReceipt,
                            ),
                            _buildActionButton(
                              icon: 'star',
                              label: 'Feedback',
                              onTap: widget.onAddFeedback,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
