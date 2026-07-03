import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class DistributionRecordsScreen extends StatefulWidget {
  const DistributionRecordsScreen({super.key});

  @override
  State<DistributionRecordsScreen> createState() => _DistributionRecordsScreenState();
}

class _DistributionRecordsScreenState extends State<DistributionRecordsScreen> {
  DistributionMethod? _methodFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDistributions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final records = _methodFilter == null
        ? provider.distributions
        : provider.distributions.where((d) => d.method == _methodFilter).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<DistributionMethod?>(
              segments: const [
                ButtonSegment(value: null, label: Text('All')),
                ButtonSegment(value: DistributionMethod.online, label: Text('Online')),
                ButtonSegment(value: DistributionMethod.offline, label: Text('Offline')),
              ],
              selected: {_methodFilter},
              onSelectionChanged: (s) => setState(() => _methodFilter = s.first),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadDistributions(),
              child: provider.isLoadingDistributions
                  ? const Center(child: CircularProgressIndicator())
                  : provider.distributionsError != null
                      ? ErrorMessage(message: provider.distributionsError!, onRetry: () => provider.loadDistributions())
                      : records.isEmpty
                          ? const EmptyListMessage(message: 'No distribution records.', icon: Icons.receipt_long)
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: records.length,
                              itemBuilder: (context, index) {
                                final dist = records[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                      child: Icon(
                                        dist.method == DistributionMethod.online ? Icons.account_balance_wallet : Icons.storefront,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                    title: Text('${dist.citizenName ?? 'Citizen'} — ৳${dist.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    subtitle: Text(
                                      '${dist.cardTypeName ?? ''} • ${distributionMethodToString(dist.method).toUpperCase()} • '
                                      '${DateFormat('dd MMM yyyy').format(dist.distributionDate)}',
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
