import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, bool> currentFilters;
  final Function(Map<String, bool>) onFiltersChanged;

  const FilterBottomSheet({
    Key? key,
    required this.currentFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, bool> filters;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text(
                'Filter Menu',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    filters = {
                      'vegetarian': false,
                      'vegan': false,
                      'glutenFree': false,
                      'spicy': false,
                      'recommended': false,
                      'available': false,
                    };
                  });
                },
                child: Text(
                  'Clear All',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Dietary Preferences',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          _buildFilterOption('Vegetarian', 'vegetarian', Colors.green),
          _buildFilterOption('Vegan', 'vegan', Colors.green),
          _buildFilterOption('Gluten Free', 'glutenFree', Colors.blue),
          SizedBox(height: 2.h),
          Text(
            'Other Filters',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          _buildFilterOption('Spicy', 'spicy', Colors.red),
          _buildFilterOption(
              'Recommended', 'recommended', AppTheme.successLight),
          _buildFilterOption(
              'Available Only', 'available', AppTheme.lightTheme.primaryColor),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    side: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFiltersChanged(filters);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, String key, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: filters[key] ?? false,
            onChanged: (value) {
              setState(() {
                filters[key] = value;
              });
            },
            activeColor: AppTheme.lightTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}