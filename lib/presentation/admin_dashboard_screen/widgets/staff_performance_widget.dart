import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class StaffPerformanceWidget extends StatelessWidget {
  final List<Map<String, dynamic>> staffData;

  const StaffPerformanceWidget({
    Key? key,
    required this.staffData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (staffData.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.people,
              size: 48.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8.sp),
            Text(
              'No staff performance data available',
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
      itemCount: staffData.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.sp),
      itemBuilder: (context, index) {
        final staff = staffData[index];
        final waiterInfo = staff['waiter_info'] as Map<String, dynamic>? ?? {};
        final totalOrders = staff['total_orders'] ?? 0;
        final totalRevenue =
            (staff['total_revenue'] as num?)?.toDouble() ?? 0.0;
        final completionRate = staff['completion_rate'] ?? 0;
        final avgOrderValue =
            (staff['average_order_value'] as num?)?.toDouble() ?? 0.0;

        return Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.sp),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Staff avatar
                  CircleAvatar(
                    radius: 20.sp,
                    backgroundColor:
                        _getAvatarColor(waiterInfo['full_name'] ?? ''),
                    child: Text(
                      _getInitials(waiterInfo['full_name'] ?? 'Unknown'),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.sp),

                  // Staff details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          waiterInfo['full_name'] ?? 'Unknown Staff',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          _getRoleDisplayName(waiterInfo['role'] ?? 'staff'),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Performance score
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                    decoration: BoxDecoration(
                      color: _getPerformanceColor(completionRate).withAlpha(26),
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Text(
                      '$completionRate%',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: _getPerformanceColor(completionRate),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.sp),

              // Performance metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                        'Orders', totalOrders.toString(), Icons.receipt),
                  ),
                  Container(
                    width: 1,
                    height: 30.sp,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _buildMetric(
                        'Revenue',
                        '\$${totalRevenue.toStringAsFixed(0)}',
                        Icons.attach_money),
                  ),
                  Container(
                    width: 1,
                    height: 30.sp,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _buildMetric(
                        'Avg Order',
                        '\$${avgOrderValue.toStringAsFixed(0)}',
                        Icons.trending_up),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Colors.grey[600],
        ),
        SizedBox(height: 4.sp),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final index = name.hashCode % colors.length;
    return colors[index.abs()];
  }

  Color _getPerformanceColor(int completionRate) {
    if (completionRate >= 90) return Colors.green;
    if (completionRate >= 75) return Colors.orange;
    return Colors.red;
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'waiter':
        return 'Waiter';
      case 'counter':
        return 'Counter Staff';
      case 'kitchen':
        return 'Kitchen Staff';
      case 'manager':
        return 'Manager';
      case 'admin':
        return 'Administrator';
      default:
        return 'Staff';
    }
  }
}
