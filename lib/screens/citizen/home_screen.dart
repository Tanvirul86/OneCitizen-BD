import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/providers/card_provider.dart';
import 'package:provider/provider.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().loadCards();
    });
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.notifications_none, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('No new notifications', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final cardProvider = context.watch<CardProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('OneCitizen BD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<CardProvider>().loadCards(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.fullName ?? 'Citizen',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (user?.citizenId != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${user!.citizenId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _QuickActionCard(
                  icon: Icons.qr_code,
                  title: 'Digital ID',
                  color: AppTheme.primaryGreen,
                  onTap: () => context.push('/citizen/identity'),
                ),
                _QuickActionCard(
                  icon: Icons.add_card,
                  title: 'Apply for Card',
                  color: AppTheme.accentRed,
                  onTap: () => context.push('/citizen/apply'),
                ),
                _QuickActionCard(
                  icon: Icons.check_circle_outline,
                  title: 'Check Eligibility',
                  color: Colors.blue,
                  onTap: () => context.push('/citizen/eligibility'),
                ),
                _QuickActionCard(
                  icon: Icons.report_problem_outlined,
                  title: 'File Complaint',
                  color: Colors.orange,
                  onTap: () => context.push('/citizen/complaints'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // My Cards Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Cards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/citizen/cards'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (cardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (cardProvider.cards.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.credit_card_off,
                        size: 48,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No cards yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push('/citizen/apply'),
                        child: const Text('Apply for a card'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...cardProvider.cards.take(3).map(
                    (card) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.credit_card,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        title: Text(card.cardTypeName),
                        subtitle: Text(card.cardNumber),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.push('/citizen/cards/${card.id}'),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
