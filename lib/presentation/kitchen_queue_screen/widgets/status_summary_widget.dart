import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatusSummaryWidget extends StatelessWidget {
  final int activeOrdersCount;
  final double averagePreparationTime;
  final int queueDepth;

  const StatusSummaryWidget({
    Key? key,
    required this.activeOrdersCount,
    required this.averagePreparationTime,
    required this.queueDepth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              icon: 'restaurant',
              title: 'Active Orders',
              value: activeOrdersCount.toString(),
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          Container(
            width: 1,
            height: 8.h,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              icon: 'timer',
              title: 'Avg. Prep Time',
              value: '${averagePreparationTime.toInt()}m',
              color: AppTheme.lightTheme.colorScheme.secondary,
            ),
          ),
          Container(
            width: 1,
            height: 8.h,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              icon: 'queue',
              title: 'Queue Depth',
              value: queueDepth.toString(),
              color: AppTheme.lightTheme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 12.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: color,
              size: 6.w,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
