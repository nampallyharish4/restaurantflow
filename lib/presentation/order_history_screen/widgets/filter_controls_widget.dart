import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterControlsWidget extends StatefulWidget {
  final String selectedStatus;
  final DateTimeRange? selectedDateRange;
  final String searchQuery;
  final Function(String) onStatusChanged;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(String) onSearchChanged;
  final VoidCallback onExport;

  const FilterControlsWidget({
    Key? key,
    required this.selectedStatus,
    this.selectedDateRange,
    required this.searchQuery,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
    required this.onSearchChanged,
    required this.onExport,
  }) : super(key: key);

  @override
  State<FilterControlsWidget> createState() => _FilterControlsWidgetState();
}

class _FilterControlsWidgetState extends State<FilterControlsWidget> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _statusOptions = [
    'All',
    'Completed',
    'Cancelled',
    'Refunded',
    'Preparing',
    'Ready'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: widget.selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateRangeChanged(picked);
    }
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return 'Select Date Range';

    final start = range.start;
    final end = range.end;

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '${start.month}/${start.day}/${start.year}';
    }

    return '${start.month}/${start.day}/${start.year} - ${end.month}/${end.day}/${end.year}';
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Export Options',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            _buildExportOption(
              icon: 'picture_as_pdf',
              title: 'Export as PDF',
              subtitle: 'Generate detailed report',
              onTap: () {
                Navigator.pop(context);
                widget.onExport();
              },
            ),
            _buildExportOption(
              icon: 'table_chart',
              title: 'Export as CSV',
              subtitle: 'Spreadsheet format',
              onTap: () {
                Navigator.pop(context);
                widget.onExport();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by Order ID, Table, or Phone',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                suffixIcon: widget.searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'clear',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          SizedBox(height: 2.h),

          // Filter Row
          Row(
            children: [
              // Date Range Picker
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'date_range',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            _formatDateRange(widget.selectedDateRange),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: widget.selectedDateRange != null
                                  ? AppTheme.lightTheme.colorScheme.onSurface
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),

              // Status Dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.selectedStatus,
                      isExpanded: true,
                      icon: CustomIconWidget(
                        iconName: 'arrow_drop_down',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          widget.onStatusChanged(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),

              // Export Button
              GestureDetector(
                onTap: _showExportOptions,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'file_download',
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // Clear Filters
          if (widget.selectedDateRange != null ||
              widget.selectedStatus != 'All' ||
              widget.searchQuery.isNotEmpty) ...[
            SizedBox(height: 2.h),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                widget.onSearchChanged('');
                widget.onStatusChanged('All');
                widget.onDateRangeChanged(null);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.h,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'clear_all',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Clear All Filters',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
