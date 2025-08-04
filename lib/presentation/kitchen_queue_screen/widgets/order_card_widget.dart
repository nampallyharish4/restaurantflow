import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrderCardWidget extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onStartPreparing;
  final VoidCallback? onMarkReady;
  final VoidCallback? onMarkDelivered;
  final VoidCallback? onAddNote;
  final VoidCallback? onRequestHelp;
  final VoidCallback? onMarkProblem;
  final VoidCallback? onLongPress;

  const OrderCardWidget({
    Key? key,
    required this.order,
    this.onStartPreparing,
    this.onMarkReady,
    this.onMarkDelivered,
    this.onAddNote,
    this.onRequestHelp,
    this.onMarkProblem,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = order['status'] ?? 'pending';
    final String orderId = order['id']?.toString() ?? '';
    final String tableNumber = order['tableNumber']?.toString() ?? '';
    final List<dynamic> items = order['items'] ?? [];
    final String specialInstructions = order['specialInstructions'] ?? '';
    final DateTime orderTime = order['orderTime'] ?? DateTime.now();
    final Duration elapsed = DateTime.now().difference(orderTime);
    final bool isPriority = order['priority'] == 'high';

    return GestureDetector(
      onLongPress: onLongPress,
      child: Dismissible(
        key: Key('order_$orderId'),
        direction: DismissDirection.startToEnd,
        background: Container(
          margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.secondary
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(width: 4.w),
              CustomIconWidget(
                iconName: 'note_add',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Add Note',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              CustomIconWidget(
                iconName: 'help_outline',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Help',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4.w),
            ],
          ),
        ),
        onDismissed: (direction) {
          onAddNote?.call();
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: isPriority
                ? Border.all(
                    color: AppTheme.lightTheme.colorScheme.error,
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with order info and priority
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    if (isPriority) ...[
                      CustomIconWidget(
                        iconName: 'priority_high',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Order #$orderId',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(status),
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'table_restaurant',
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                size: 4.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Table $tableNumber',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            color: elapsed.inMinutes > 15
                                ? AppTheme.lightTheme.colorScheme.error
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'elapsed',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Items list
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items:',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    ...items.map((item) {
                      final Map<String, dynamic> itemData =
                          item as Map<String, dynamic>;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 0.5.h),
                        child: Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 3.h,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  '${itemData['quantity'] ?? 1}',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemData['name'] ?? '',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (itemData['customizations'] != null &&
                                      (itemData['customizations'] as List)
                                          .isNotEmpty)
                                    Text(
                                      (itemData['customizations'] as List)
                                          .join(', '),
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Special instructions
                    if (specialInstructions.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.tertiary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.tertiary
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'info_outline',
                                  color:
                                      AppTheme.lightTheme.colorScheme.tertiary,
                                  size: 4.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Special Instructions:',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              specialInstructions,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: _buildActionButtons(status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    switch (status) {
      case 'approved':
        return SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton.icon(
            onPressed: onStartPreparing,
            icon: CustomIconWidget(
              iconName: 'play_arrow',
              color: Colors.white,
              size: 5.w,
            ),
            label: Text(
              'Start Preparing',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      case 'preparing':
        return SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton.icon(
            onPressed: onMarkReady,
            icon: CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            label: Text(
              'Mark Ready',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      case 'ready':
        return SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton.icon(
            onPressed: onMarkDelivered,
            icon: CustomIconWidget(
              iconName: 'delivery_dining',
              color: Colors.white,
              size: 5.w,
            ),
            label: Text(
              'Mark Delivered',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      default:
        return Container(
          width: double.infinity,
          height: 6.h,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Waiting for Approval',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'delivered':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'APPROVED';
      case 'preparing':
        return 'PREPARING';
      case 'ready':
        return 'READY';
      case 'delivered':
        return 'DELIVERED';
      default:
        return 'PENDING';
    }
  }
}
