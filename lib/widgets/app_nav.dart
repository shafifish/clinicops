import 'package:flutter/material.dart';

import '../app_routes.dart';

/// Bottom navigation shared by the four main screens.
class AppNav extends StatelessWidget {
  const AppNav({super.key, required this.current});

  /// 0 Home, 1 Stock, 2 Tasks, 3 Reports.
  final int current;

  static const List<String> _routes = [
    AppRoutes.dashboard,
    AppRoutes.stock,
    AppRoutes.tasks,
    AppRoutes.reports,
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current,
      onDestinationSelected: (index) {
        if (index == current) return;
        Navigator.pushReplacementNamed(context, _routes[index]);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Stock',
        ),
        NavigationDestination(
          icon: Icon(Icons.check_circle_outline),
          label: 'Tasks',
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          label: 'Reports',
        ),
      ],
    );
  }
}
