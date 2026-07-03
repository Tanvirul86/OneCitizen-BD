import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/providers/distribution_provider.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class DistributionHistoryScreen extends StatefulWidget {
  const DistributionHistoryScreen({super.key});

  @override
  State<DistributionHistoryScreen> createState() => _DistributionHistoryScreenState();
}

class _DistributionHistoryScreenState extends State<DistributionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistributionProvider>().loadDistributions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DistributionProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('Distribution History')),
      body: RefreshIndicator(
        onRefresh: () => provider.loadDistributions(),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? ErrorMessage(message: provider.error!, onRetry: () => provider.loadDistributions())
                : provider.distributions.isEmpty
                    ? const EmptyListMessage(message: 'No fund disbursements yet.', icon: Icons.payments_outlined)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.distributions.length,
                        itemBuilder: (context, index) {
                          final dist = provider.distributions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                child: Icon(
                                  dist.method == DistributionMethod.online ? Icons.account_balance_wallet : Icons.storefront,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              title: Text('৳${dist.amount.toStringAsFixed(0)} — ${dist.cardTypeName ?? ''}'),
                              subtitle: Text(
                                '${distributionMethodToString(dist.method).toUpperCase()} • '
                                '${DateFormat('dd MMM yyyy').format(dist.distributionDate)}'
                                '${dist.note != null ? '\n${dist.note}' : ''}',
                              ),
                              isThreeLine: dist.note != null,
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
