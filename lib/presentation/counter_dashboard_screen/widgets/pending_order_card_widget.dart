import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PendingOrderCardWidget extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const PendingOrderCardWidget({
    Key? key,
    required this.order,
    required this.onApprove,
    required this.onReject,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  String _getElapsedTime() {
    final DateTime orderTime = order['timestamp'] as DateTime;
    final Duration elapsed = DateTime.now().difference(orderTime);

    if (elapsed.inMinutes < 1) {
      return 'Just now';
    } else if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes}m ago';
    } else {
      return '${elapsed.inHours}h ${elapsed.inMinutes % 60}m ago';
    }
  }

  Color _getPriorityColor() {
    final DateTime orderTime = order['timestamp'] as DateTime;
    final Duration elapsed = DateTime.now().difference(orderTime);

    if (elapsed.inMinutes > 15) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (elapsed.inMinutes > 10) {
      return const Color(0xFFF18701); // Warning color
    } else {
      return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = (order['status'] as String?) ?? 'pending';
    final Color priorityColor = _getPriorityColor();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      onLongPress: onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              onLongPress!();
            }
          : null,
      child: Dismissible(
        key: Key('order_${order['id']}'),
        background: Container(
          margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Approve',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'cancel',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Reject',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          HapticFeedback.mediumImpact();
          if (direction == DismissDirection.startToEnd) {
            onApprove();
          } else {
            onReject();
          }
          return false; // Don't actually dismiss, let the callback handle it
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: priorityColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow
                    .withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Order #${order['id']}',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'table_restaurant',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Table ${order['tableNumber']}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'restaurant_menu',
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '${(order['items'] as List).length} items',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'access_time',
                              color: priorityColor,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _getElapsedTime(),
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: priorityColor,
                                fontWeight: FontWeight.w500,
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
                        order['total'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: status == 'pending'
                              ? const Color(0xFF2E86AB).withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.tertiary
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: status == 'pending'
                                ? const Color(0xFF2E86AB)
                                : AppTheme.lightTheme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (status == 'pending') ...[
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onApprove();
                        },
                        icon: CustomIconWidget(
                          iconName: 'check_circle',
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.tertiary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onReject();
                        },
                        icon: CustomIconWidget(
                          iconName: 'cancel',
                          color: AppTheme.lightTheme.colorScheme.error,
                          size: 18,
                        ),
                        label: Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              AppTheme.lightTheme.colorScheme.error,
                          side: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.error,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
