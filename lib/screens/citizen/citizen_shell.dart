import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';

class CitizenShell extends StatelessWidget {
  const CitizenShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return PopScope(
      canPop: location == '/citizen',
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/citizen');
      },
      child: Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textSecondary,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: context.tr('admin_nav_dashboard')),
          BottomNavigationBarItem(icon: const Icon(Icons.assignment), label: context.tr('citizen_nav_applications')),
          BottomNavigationBarItem(icon: const Icon(Icons.payments), label: context.tr('citizen_nav_funds')),
          BottomNavigationBarItem(icon: const Icon(Icons.notifications), label: context.tr('notifications_title')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: context.tr('citizen_nav_profile')),
        ],
      ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/citizen/applications')) return 1;
    if (location.startsWith('/citizen/distributions')) return 2;
    if (location.startsWith('/citizen/notifications')) return 3;
    if (location.startsWith('/citizen/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/citizen');
        break;
      case 1:
        context.go('/citizen/applications');
        break;
      case 2:
        context.go('/citizen/distributions');
        break;
      case 3:
        context.go('/citizen/notifications');
        break;
      case 4:
        context.go('/citizen/profile');
        break;
    }
  }
}
