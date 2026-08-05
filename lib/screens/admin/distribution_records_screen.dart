import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class DistributionRecordsScreen extends StatefulWidget {
  const DistributionRecordsScreen({super.key});

  @override
  State<DistributionRecordsScreen> createState() =>
      _DistributionRecordsScreenState();
}

class _DistributionRecordsScreenState extends State<DistributionRecordsScreen> {
  DistributionMethod? _methodFilter;
  String? _selectedCardTypeName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDistributions();
      context.read<ApplicationProvider>().loadCardTypes();
    });
  }

  ({IconData icon, Color color}) _styleFor(CardTypeCode code) {
    switch (code) {
      case CardTypeCode.farmer:
        return (
          icon: Icons.agriculture_rounded,
          color: const Color(0xFF059669),
        );
      case CardTypeCode.family:
        return (
          icon: Icons.family_restroom_rounded,
          color: const Color(0xFF2563EB),
        );
      case CardTypeCode.education:
        return (icon: Icons.school_rounded, color: const Color(0xFF7C3AED));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final cardTypes = context.watch<ApplicationProvider>().cardTypes;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: provider.isLoadingDistributions
          ? const Center(child: CircularProgressIndicator())
          : provider.distributionsError != null
          ? ErrorMessage(
              message: provider.distributionsError!,
              onRetry: () => provider.loadDistributions(),
            )
          : _selectedCardTypeName == null
          ? _buildCardTypeSummary(provider, cardTypes)
          : _buildCardTypeDetail(provider),
    );
  }

  Widget _buildCardTypeSummary(
    AdminProvider provider,
    List<CardType> cardTypes,
  ) {
    if (cardTypes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadDistributions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cardTypes.length,
        itemBuilder: (context, index) {
          final cardType = cardTypes[index];
          final records = provider.distributions
              .where((d) => d.cardTypeName == cardType.name)
              .toList();
          final total = records.fold<double>(0, (sum, d) => sum + d.amount);
          final style = _styleFor(cardType.code);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  setState(() => _selectedCardTypeName = cardType.name),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: style.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(style.icon, color: style.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cardType.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.trp('recipients_count_label', {
                              'count': '${records.length}',
                            }),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '৳${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.textTertiary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardTypeDetail(AdminProvider provider) {
    final cardTypeName = _selectedCardTypeName!;
    final records = provider.distributions
        .where(
          (d) =>
              d.cardTypeName == cardTypeName &&
              (_methodFilter == null || d.method == _methodFilter),
        )
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _selectedCardTypeName = null),
              ),
              Expanded(
                child: Text(
                  cardTypeName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<DistributionMethod?>(
            segments: [
              ButtonSegment(value: null, label: Text(context.tr('filter_all'))),
              ButtonSegment(
                value: DistributionMethod.online,
                label: Text(context.tr('online')),
              ),
              ButtonSegment(
                value: DistributionMethod.offline,
                label: Text(context.tr('offline')),
              ),
            ],
            selected: {_methodFilter},
            onSelectionChanged: (s) => setState(() => _methodFilter = s.first),
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? EmptyListMessage(
                  message: context.tr('no_distribution_records'),
                  icon: Icons.receipt_long,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final dist = records[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withValues(
                            alpha: 0.1,
                          ),
                          child: Icon(
                            dist.method == DistributionMethod.online
                                ? Icons.account_balance_wallet
                                : Icons.storefront,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        title: Text(
                          '${dist.citizenName ?? 'Citizen'} — ৳${dist.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${(dist.method == DistributionMethod.online ? context.tr('online') : context.tr('offline')).toUpperCase()} • '
                          '${DateFormat('dd MMM yyyy').format(dist.distributionDate)}',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
