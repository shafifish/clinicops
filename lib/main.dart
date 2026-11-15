import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'screens/ai_review_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/handover_screen.dart';
import 'screens/login_screen.dart';
import 'screens/report_history_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/stock_screen.dart';
import 'screens/tasks_screen.dart';

void main() {
  runApp(const ClinicOpsApp());
}

class ClinicOpsApp extends StatelessWidget {
  const ClinicOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinicOps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.stock: (context) => const StockScreen(),
        AppRoutes.tasks: (context) => const TasksScreen(),
        AppRoutes.handover: (context) => const HandoverScreen(),
        AppRoutes.reports: (context) => const ReportsScreen(),
        AppRoutes.aiReview: (context) => const AiReviewScreen(),
        AppRoutes.reportHistory: (context) => const ReportHistoryScreen(),
      },
    );
  }
}
