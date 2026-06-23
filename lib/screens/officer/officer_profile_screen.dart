import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OfficerProfileScreen extends StatelessWidget {
  const OfficerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 56,
              backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.12),
              backgroundImage: user?.profilePictureUrl != null
                  ? NetworkImage(user!.profilePictureUrl!) as ImageProvider
                  : null,
              child: user?.profilePictureUrl == null
                  ? const Icon(Icons.person, size: 56, color: AppTheme.primaryGreen)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          _InfoCard(
            children: [
              _Row(label: 'Name', value: user?.fullName ?? 'N/A'),
              _Row(label: 'Phone', value: user?.phoneNumber ?? 'N/A'),
              _Row(label: 'Role', value: 'Officer'),
              if (user?.email != null) _Row(label: 'Email', value: user!.email!),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
