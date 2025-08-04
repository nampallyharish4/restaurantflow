import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SkeletonLoadingWidget extends StatefulWidget {
  const SkeletonLoadingWidget({Key? key}) : super(key: key);

  @override
  State<SkeletonLoadingWidget> createState() => _SkeletonLoadingWidgetState();
}

class _SkeletonLoadingWidgetState extends State<SkeletonLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.outline
                .withValues(alpha: _animation.value * 0.3),
            borderRadius: borderRadius ?? BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildShimmerContainer(
                          width: 20.w,
                          height: 2.h,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        SizedBox(width: 2.w),
                        _buildShimmerContainer(
                          width: 15.w,
                          height: 2.h,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        _buildShimmerContainer(
                          width: 3.w,
                          height: 1.5.h,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        SizedBox(width: 1.w),
                        _buildShimmerContainer(
                          width: 18.w,
                          height: 1.5.h,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        SizedBox(width: 4.w),
                        _buildShimmerContainer(
                          width: 3.w,
                          height: 1.5.h,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        SizedBox(width: 1.w),
                        _buildShimmerContainer(
                          width: 15.w,
                          height: 1.5.h,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildShimmerContainer(
                    width: 20.w,
                    height: 2.5.h,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  SizedBox(height: 1.h),
                  _buildShimmerContainer(
                    width: 6.w,
                    height: 2.h,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => _buildSkeletonCard(),
      ),
    );
  }
}
