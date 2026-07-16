import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/widgets/admin_quick_search.dart';
import 'package:onecitizen/widgets/app_logo.dart';
import 'package:provider/provider.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const _items = [
    (path: '/admin', icon: Icons.dashboard_rounded, label: 'Dashboard'),
    (path: '/admin/applications', icon: Icons.assignment_rounded, label: 'New Applications'),
    (path: '/admin/documents', icon: Icons.fact_check_rounded, label: 'Document Validation'),
    (path: '/admin/approved-cards', icon: Icons.credit_card_rounded, label: 'Approved Cards'),
    (path: '/admin/distributions/new', icon: Icons.payments_rounded, label: 'Fund Distribution'),
    (path: '/admin/distributions', icon: Icons.receipt_long_rounded, label: 'Distribution Records'),
    (path: '/admin/citizens', icon: Icons.people_rounded, label: 'Citizen Accounts'),
    (path: '/admin/analytics', icon: Icons.bar_chart_rounded, label: 'Analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final user = context.watch<AuthProvider>().user;

    final currentTitle = _items.firstWhere(
      (item) => item.path == location,
      orElse: () => _items.first,
    ).label;

    return PopScope(
      canPop: location == '/admin',
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/admin');
      },
      child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 28, onDark: true, linkToLanding: true),
            const SizedBox(width: 8),
            Text(currentTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          const AdminQuickSearchButton(),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(size: 52, onDark: true, linkToLanding: true),
                  const SizedBox(height: 16),
                  const Text(
                    'OneCitizen BD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.fullName.isNotEmpty == true ? user!.fullName : 'Administrator',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final item in _items) ...[
                    _DrawerItem(
                      icon: item.icon,
                      label: item.label,
                      selected: location == item.path,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(item.path);
                      },
                    ),
                  ],
                ],
              ),
            ),
            // Footer
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppTheme.accentRed),
              title: const Text('Logout', style: TextStyle(color: AppTheme.accentRed)),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthProvider>().logout();
                if (context.mounted) context.go('/login');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
        body: child,
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? AppTheme.primaryGreen : AppTheme.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.primaryGreen : AppTheme.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
      ),
    );
  }
}
