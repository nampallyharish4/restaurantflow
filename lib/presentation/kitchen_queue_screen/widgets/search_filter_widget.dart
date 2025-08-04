import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final String currentFilter;

  const SearchFilterWidget({
    Key? key,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.currentFilter,
  }) : super(key: key);

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          // Search bar
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isSearchExpanded ? 7.h : 0,
            child: _isSearchExpanded
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'search',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          size: 5.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: widget.onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search by table number or item...',
                              border: InputBorder.none,
                              hintStyle: AppTheme
                                  .lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchChanged('');
                            setState(() {
                              _isSearchExpanded = false;
                            });
                          },
                          icon: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 5.w,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
          ),

          if (_isSearchExpanded) SizedBox(height: 2.h),

          // Filter chips and search toggle
          Row(
            children: [
              if (!_isSearchExpanded)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = true;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                  tooltip: 'Search Orders',
                ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Approved', 'approved'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Preparing', 'preparing'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Ready', 'ready'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Priority', 'priority'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = widget.currentFilter == value;

    return GestureDetector(
      onTap: () => widget.onFilterChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
