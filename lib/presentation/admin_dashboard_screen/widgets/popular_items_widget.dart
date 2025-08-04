import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PopularItemsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> popularItems;

  const PopularItemsWidget({
    Key? key,
    required this.popularItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (popularItems.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 48.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8.sp),
            Text(
              'No popular items data available',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: popularItems.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.sp),
      itemBuilder: (context, index) {
        final item = popularItems[index];
        final menuItem = item['menu_item'] as Map<String, dynamic>? ?? {};
        final totalQuantity = item['total_quantity'] ?? 0;
        final totalRevenue = (item['total_revenue'] as num?)?.toDouble() ?? 0.0;
        final orderCount = item['order_count'] ?? 0;

        return Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.sp),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 24.sp,
                height: 24.sp,
                decoration: BoxDecoration(
                  color: _getRankColor(index),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.sp),

              // Item image
              Container(
                width: 40.sp,
                height: 40.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.sp),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.sp),
                  child: menuItem['image_url'] != null
                      ? CachedNetworkImage(
                          imageUrl: menuItem['image_url'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                            Icons.restaurant,
                            color: Colors.grey[400],
                            size: 20.sp,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.restaurant,
                            color: Colors.grey[400],
                            size: 20.sp,
                          ),
                        )
                      : Icon(
                          Icons.restaurant,
                          color: Colors.grey[400],
                          size: 20.sp,
                        ),
                ),
              ),
              SizedBox(width: 12.sp),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuItem['name'] ?? 'Unknown Item',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.sp),
                    Row(
                      children: [
                        Text(
                          '$totalQuantity sold',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          ' • ',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          '$orderCount orders',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Revenue
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${totalRevenue.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    'revenue',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey[400]!; // Silver
      case 2:
        return Colors.brown; // Bronze
      default:
        return Colors.blue[400]!;
    }
  }
}
