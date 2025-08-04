import 'package:flutter/material.dart';

import '../presentation/admin_dashboard_screen/admin_dashboard_screen.dart';
import '../presentation/counter_dashboard_screen/counter_dashboard_screen.dart';
import '../presentation/kitchen_queue_screen/kitchen_queue_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/menu_selection_screen/menu_selection_screen.dart';
import '../presentation/order_history_screen/order_history_screen.dart';
import '../presentation/table_detail_screen/table_detail_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String tableDetail = '/table-detail-screen';
  static const String login = '/login-screen';
  static const String menuSelection = '/menu-selection-screen';
  static const String kitchenQueue = '/kitchen-queue-screen';
  static const String counterDashboard = '/counter-dashboard-screen';
  static const String orderHistory = '/order-history-screen';
  static const String adminDashboard = '/admin-dashboard-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    tableDetail: (context) => const TableDetailScreen(),
    login: (context) => const LoginScreen(),
    menuSelection: (context) => const MenuSelectionScreen(),
    kitchenQueue: (context) => const KitchenQueueScreen(),
    counterDashboard: (context) => const CounterDashboardScreen(),
    orderHistory: (context) => const OrderHistoryScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    // TODO: Add your other routes here
  };
}