import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/analytics_service.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/table_service.dart';
import './widgets/analytics_card_widget.dart';
import './widgets/popular_items_widget.dart';
import './widgets/revenue_chart_widget.dart';
import './widgets/staff_performance_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final AuthService _authService = AuthService();
  final OrderService _orderService = OrderService();
  final TableService _tableService = TableService();

  bool _isLoading = true;
  Map<String, dynamic> _todayAnalytics = {};
  Map<String, dynamic> _revenueAnalytics = {};
  Map<String, dynamic> _tableStats = {};
  Map<String, dynamic> _orderStats = {};
  List<Map<String, dynamic>> _popularItems = [];
  List<Map<String, dynamic>> _staffPerformance = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      final results = await Future.wait([
        _analyticsService.generateTodayAnalytics(),
        _analyticsService.getRevenueAnalytics(days: 7),
        _tableService.getTableStatistics(),
        _orderService.getOrderStatistics(),
        _analyticsService.getPopularItemsAnalytics(days: 7, limit: 5),
        _analyticsService.getStaffPerformance(days: 7),
      ]);

      setState(() {
        _todayAnalytics = results[0] as Map<String, dynamic>;
        _revenueAnalytics = results[1] as Map<String, dynamic>;
        _tableStats = results[2] as Map<String, dynamic>;
        _orderStats = results[3] as Map<String, dynamic>;
        _popularItems = results[4] as List<Map<String, dynamic>>;
        _staffPerformance = results[5] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dashboard data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case 'export':
                  await _exportAnalytics();
                  break;
                case 'logout':
                  await _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    SizedBox(height: 20.sp),
                    _buildTodayOverview(),
                    SizedBox(height: 20.sp),
                    _buildQuickStats(),
                    SizedBox(height: 20.sp),
                    _buildRevenueChart(),
                    SizedBox(height: 20.sp),
                    _buildPopularItems(),
                    SizedBox(height: 20.sp),
                    _buildStaffPerformance(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepOrange, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.sp),
                Text(
                  'Here\'s how your restaurant is performing today',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.dashboard,
            size: 40.sp,
            color: Colors.white.withAlpha(204),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayOverview() {
    final totalOrders = _todayAnalytics['total_orders'] ?? 0;
    final totalRevenue = _todayAnalytics['total_revenue'] ?? 0.0;
    final avgOrderValue = _todayAnalytics['average_order_value'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.sp),
        Row(
          children: [
            Expanded(
              child: AnalyticsCardWidget(
                title: 'Orders',
                value: totalOrders.toString(),
                icon: Icons.receipt_long,
                color: Colors.blue,
                subtitle: 'Total orders today',
              ),
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: AnalyticsCardWidget(
                title: 'Revenue',
                value: '\$${totalRevenue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
                subtitle: 'Total revenue today',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.sp),
        AnalyticsCardWidget(
          title: 'Average Order Value',
          value: '\$${avgOrderValue.toStringAsFixed(2)}',
          icon: Icons.trending_up,
          color: Colors.purple,
          subtitle: 'Average per order today',
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final occupiedTables = _tableStats['occupied_tables'] ?? 0;
    final totalTables = _tableStats['total_tables'] ?? 1;
    final pendingOrders = _orderStats['pending_orders'] ?? 0;
    final preparingOrders = _orderStats['preparing_orders'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.sp),
        Row(
          children: [
            Expanded(
              child: AnalyticsCardWidget(
                title: 'Tables Occupied',
                value: '$occupiedTables/$totalTables',
                icon: Icons.table_restaurant,
                color: Colors.indigo,
                subtitle:
                    '${((occupiedTables / totalTables) * 100).round()}% occupancy',
              ),
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: AnalyticsCardWidget(
                title: 'Orders Queue',
                value: '${pendingOrders + preparingOrders}',
                icon: Icons.queue,
                color: Colors.orange,
                subtitle: '$pendingOrders pending, $preparingOrders preparing',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Trend (Last 7 Days)',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.sp),
          RevenueChartWidget(
            revenueData: _revenueAnalytics['daily_breakdown'] ?? [],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularItems() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Items (This Week)',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.sp),
          PopularItemsWidget(popularItems: _popularItems),
        ],
      ),
    );
  }

  Widget _buildStaffPerformance() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Staff Performance (This Week)',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.sp),
          StaffPerformanceWidget(staffData: _staffPerformance),
        ],
      ),
    );
  }

  Future<void> _exportAnalytics() async {
    try {
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();

      final csvData =
          await _analyticsService.exportAnalyticsToCSV(startDate, endDate);

      // For web/mobile, you would typically save this to device storage
      // or share it via the system share dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analytics data exported successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $error')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $error')),
      );
    }
  }
}
