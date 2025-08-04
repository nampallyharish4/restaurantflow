import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrderItemCard extends StatelessWidget {
  final Map<String, dynamic> orderItem;
  final VoidCallback? onEdit;
  final VoidCallback? onAddNote;
  final VoidCallback? onCancel;
  final VoidCallback? onLongPress;

  const OrderItemCard({
    Key? key,
    required this.orderItem,
    this.onEdit,
    this.onAddNote,
    this.onCancel,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('order_item_${orderItem['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
                'edit', AppTheme.lightTheme.colorScheme.primary, onEdit),
            SizedBox(width: 2.w),
            _buildActionButton('note_add', Colors.orange, onAddNote),
            SizedBox(width: 2.w),
            _buildActionButton(
                'cancel', AppTheme.lightTheme.colorScheme.error, onCancel),
          ],
        ),
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderItem['name'] as String,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        if (orderItem['customizations'] != null &&
                            (orderItem['customizations'] as List)
                                .isNotEmpty) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            (orderItem['customizations'] as List).join(', '),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Qty: ${orderItem['quantity']}',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        orderItem['price'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(orderItem['status'] as String),
                  if (orderItem['note'] != null &&
                      (orderItem['note'] as String).isNotEmpty)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 3.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'note',
                              color: Colors.amber[700]!,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                orderItem['note'] as String,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.amber[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String iconName, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'ordered':
        chipColor = Colors.blue;
        textColor = Colors.white;
        break;
      case 'preparing':
        chipColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'ready':
        chipColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'delivered':
        chipColor = Colors.grey;
        textColor = Colors.white;
        break;
      default:
        chipColor = AppTheme.lightTheme.colorScheme.primary;
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
}
