import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrderHistoryItem extends StatelessWidget {
  final Map<String, dynamic> historyItem;

  const OrderHistoryItem({
    Key? key,
    required this.historyItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderTime = historyItem['orderTime'] as DateTime;
    final completedTime = historyItem['completedTime'] as DateTime?;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${historyItem['orderId']}',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              _buildStatusChip(historyItem['status'] as String),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                'Ordered: ${_formatTime(orderTime)}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              if (completedTime != null) ...[
                SizedBox(width: 4.w),
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.green,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Completed: ${_formatTime(completedTime)}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 2.h),
          Column(
            children: (historyItem['items'] as List<Map<String, dynamic>>)
                .map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item['quantity']}x ${item['name']}',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      item['price'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            thickness: 1,
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                historyItem['total'] as String,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'cancelled':
        chipColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'partial':
        chipColor = Colors.orange;
        textColor = Colors.white;
        break;
      default:
        chipColor = Colors.grey;
        textColor = Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
