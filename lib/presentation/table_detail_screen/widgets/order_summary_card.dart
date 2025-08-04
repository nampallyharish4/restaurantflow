import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrderSummaryCard extends StatelessWidget {
  final Map<String, dynamic> orderSummary;
  final VoidCallback? onGenerateBill;

  const OrderSummaryCard({
    Key? key,
    required this.orderSummary,
    this.onGenerateBill,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow('Subtotal', orderSummary['subtotal'] as String),
          SizedBox(height: 1.h),
          _buildSummaryRow('Tax (${orderSummary['taxRate']}%)',
              orderSummary['tax'] as String),
          SizedBox(height: 1.h),
          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            thickness: 1,
          ),
          SizedBox(height: 1.h),
          _buildSummaryRow(
            'Total',
            orderSummary['total'] as String,
            isTotal: true,
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: onGenerateBill,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'receipt',
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Generate Bill',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontSize: isTotal ? 16.sp : 14.sp,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurface,
            fontSize: isTotal ? 16.sp : 14.sp,
          ),
        ),
      ],
    );
  }
}
