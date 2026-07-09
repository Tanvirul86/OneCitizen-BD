import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final analytics = provider.analytics ?? {};
    final byCardType = (analytics['applications_by_card_type'] as Map<String, dynamic>?) ?? {};

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: provider.isLoadingAnalytics
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadAnalytics(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _StatTile(label: 'Total Applications', value: '${analytics['total_applications'] ?? 0}', icon: Icons.assignment_rounded, color: AppTheme.primaryGreen),
                      _StatTile(label: 'Approved', value: '${analytics['approved'] ?? 0}', icon: Icons.check_circle_rounded, color: AppTheme.successGreen),
                      _StatTile(label: 'Rejected', value: '${analytics['rejected'] ?? 0}', icon: Icons.cancel_rounded, color: AppTheme.errorRed),
                      _StatTile(label: 'Pending Review', value: '${analytics['pending_review'] ?? 0}', icon: Icons.hourglass_empty_rounded, color: AppTheme.warningAmber),
                      _StatTile(label: 'Pending Documents', value: '${analytics['pending_document_reviews'] ?? 0}', icon: Icons.fact_check_rounded, color: AppTheme.infoBlue),
                      _StatTile(label: 'Total Disbursed', value: '৳${analytics['total_disbursed'] ?? 0}', icon: Icons.payments_rounded, color: AppTheme.primaryGreen),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Applications by Card Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: byCardType.entries
                          .map((e) => ListTile(
                                title: Text(e.key.toString()),
                                trailing: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                onTap: () => context.push('/admin/applications', extra: e.key.toString()),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon, this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppTheme.primaryGreen;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: tileColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: tileColor, size: 16),
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
