import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class MenuItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>, int) onQuantityChanged;

  const MenuItemCard({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  int quantity = 0;

  void _updateQuantity(int newQuantity) {
    setState(() {
      quantity = newQuantity;
    });
    widget.onQuantityChanged(widget.item, newQuantity);
  }

  void _showItemDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
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
            Text(
              widget.item['name'] as String,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Ingredients: ${widget.item['ingredients'] as String}',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            if ((widget.item['allergens'] as List).isNotEmpty)
              Text(
                'Allergens: ${(widget.item['allergens'] as List).join(', ')}',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.errorLight,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.item['isOutOfStock'] as bool? ?? false;
    final isRecommended = widget.item['isRecommended'] as bool? ?? false;

    return GestureDetector(
      onLongPress: _showItemDetails,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomImageWidget(
                          imageUrl: widget.item['image'] as String,
                          width: 20.w,
                          height: 20.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (isOutOfStock)
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Out of\nStock',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.item['name'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.item['isVegetarian'] as bool? ?? false)
                              Container(
                                margin: EdgeInsets.only(left: 2.w),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.green, width: 1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: CustomIconWidget(
                                  iconName: 'circle',
                                  color: Colors.green,
                                  size: 8,
                                ),
                              ),
                            if (widget.item['isVegan'] as bool? ?? false)
                              Container(
                                margin: EdgeInsets.only(left: 1.w),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.green, width: 1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: CustomIconWidget(
                                  iconName: 'eco',
                                  color: Colors.green,
                                  size: 8,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          widget.item['description'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Text(
                              widget.item['price'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.lightTheme.primaryColor,
                              ),
                            ),
                            const Spacer(),
                            if (quantity == 0 && !isOutOfStock)
                              ElevatedButton(
                                onPressed: () => _updateQuantity(1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.lightTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 1.h),
                                  minimumSize: Size(16.w, 5.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Add',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (quantity > 0)
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _updateQuantity(quantity - 1),
                                      child: Container(
                                        padding: EdgeInsets.all(1.w),
                                        child: CustomIconWidget(
                                          iconName: 'remove',
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 3.w),
                                      child: Text(
                                        quantity.toString(),
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          _updateQuantity(quantity + 1),
                                      child: Container(
                                        padding: EdgeInsets.all(1.w),
                                        child: CustomIconWidget(
                                          iconName: 'add',
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if ((widget.item['customizations'] as List).isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(top: 1.h),
                            child: Wrap(
                              spacing: 1.w,
                              children: (widget.item['customizations'] as List)
                                  .map<Widget>((customization) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightTheme.colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    customization as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.lightTheme.primaryColor,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isRecommended)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Recommended',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}