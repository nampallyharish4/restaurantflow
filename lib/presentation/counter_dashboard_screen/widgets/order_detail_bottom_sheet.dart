import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrderDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onAddNote;
  final VoidCallback? onContactWaiter;
  final VoidCallback? onModifyItems;

  const OrderDetailBottomSheet({
    Key? key,
    required this.order,
    this.onApprove,
    this.onReject,
    this.onAddNote,
    this.onContactWaiter,
    this.onModifyItems,
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
      return const Color(0xFFF18701);
    } else {
      return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = (order['status'] as String?) ?? 'pending';
    final Color priorityColor = _getPriorityColor();
    final List<dynamic> items = order['items'] as List<dynamic>;

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Order #${order['id']}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 24,
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
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'table_restaurant',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Table ${order['tableNumber']}',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: status == 'pending'
                                    ? const Color(0xFF2E86AB)
                                        .withValues(alpha: 0.1)
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
                                      : AppTheme
                                          .lightTheme.colorScheme.tertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'access_time',
                                    color: priorityColor,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    _getElapsedTime(),
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: priorityColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'person',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  size: 16,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  order['waiterName'] as String,
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Items section
                  Text(
                    'Order Items',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => SizedBox(height: 1.h),
                    itemBuilder: (context, index) {
                      final item = items[index] as Map<String, dynamic>;
                      return Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: AppTheme
                                    .lightTheme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${item['quantity']}x',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
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
                                    item['name'] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item['customizations'] != null &&
                                      (item['customizations'] as List)
                                          .isNotEmpty) ...[
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      (item['customizations'] as List)
                                          .join(', '),
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              item['price'] as String,
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Total section
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Total Amount',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          order['total'] as String,
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action buttons
          if (status == 'pending')
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onAddNote != null
                              ? () {
                                  HapticFeedback.lightImpact();
                                  onAddNote!();
                                }
                              : null,
                          icon: CustomIconWidget(
                            iconName: 'note_add',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            size: 18,
                          ),
                          label: Text('Add Note'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme
                                .lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            side: BorderSide(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onContactWaiter != null
                              ? () {
                                  HapticFeedback.lightImpact();
                                  onContactWaiter!();
                                }
                              : null,
                          icon: CustomIconWidget(
                            iconName: 'call',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            size: 18,
                          ),
                          label: Text('Contact'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme
                                .lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            side: BorderSide(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onModifyItems != null
                              ? () {
                                  HapticFeedback.lightImpact();
                                  onModifyItems!();
                                }
                              : null,
                          icon: CustomIconWidget(
                            iconName: 'edit',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            size: 18,
                          ),
                          label: Text('Modify'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme
                                .lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            side: BorderSide(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onApprove != null
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  onApprove!();
                                  Navigator.pop(context);
                                }
                              : null,
                          icon: CustomIconWidget(
                            iconName: 'check_circle',
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text('Approve Order'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.lightTheme.colorScheme.tertiary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReject != null
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  onReject!();
                                  Navigator.pop(context);
                                }
                              : null,
                          icon: CustomIconWidget(
                            iconName: 'cancel',
                            color: AppTheme.lightTheme.colorScheme.error,
                            size: 20,
                          ),
                          label: Text('Reject Order'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                AppTheme.lightTheme.colorScheme.error,
                            side: BorderSide(
                              color: AppTheme.lightTheme.colorScheme.error,
                              width: 1.5,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
