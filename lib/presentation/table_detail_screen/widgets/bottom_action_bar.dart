import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback? onCallWaiter;
  final VoidCallback? onRequestCheck;

  const BottomActionBar({
    Key? key,
    this.onCallWaiter,
    this.onRequestCheck,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCallWaiter,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                  side: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 1.5,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'support_agent',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Call Waiter',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: ElevatedButton(
                onPressed: onRequestCheck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'payment',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Request Check',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
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
      ),
    );
  }
}
