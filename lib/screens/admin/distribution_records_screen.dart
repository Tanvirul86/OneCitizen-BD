import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/utils/distribution_report_pdf.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class DistributionRecordsScreen extends StatefulWidget {
  const DistributionRecordsScreen({super.key});

  @override
  State<DistributionRecordsScreen> createState() =>
      _DistributionRecordsScreenState();
}

enum _PeriodType { weekly, monthly, yearly }

class _DistributionRecordsScreenState extends State<DistributionRecordsScreen> {
  String? _selectedCardTypeName;
  bool _viewByPeriod = false;
  _PeriodType _periodType = _PeriodType.monthly;
  int _periodOffset = 0;
  bool _isGeneratingPdf = false;

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

  ({DateTime start, DateTime end, String label}) _periodRange(int offset) {
    final now = DateTime.now();
    switch (_periodType) {
      case _PeriodType.weekly:
        final startOfThisWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        final start = startOfThisWeek.add(Duration(days: 7 * offset));
        final end = start.add(const Duration(days: 7));
        return (
          start: start,
          end: end,
          label:
              '${DateFormat('dd MMM').format(start)} – '
              '${DateFormat('dd MMM yyyy').format(end.subtract(const Duration(days: 1)))}',
        );
      case _PeriodType.monthly:
        final start = DateTime(now.year, now.month + offset, 1);
        final end = DateTime(now.year, now.month + offset + 1, 1);
        return (
          start: start,
          end: end,
          label: DateFormat('MMMM yyyy').format(start),
        );
      case _PeriodType.yearly:
        final start = DateTime(now.year + offset, 1, 1);
        final end = DateTime(now.year + offset + 1, 1, 1);
        return (
          start: start,
          end: end,
          label: DateFormat('yyyy').format(start),
        );
    }
  }

  // Called from _downloadPdf, an event handler — must use the non-reactive
  // trs() (build()-only context.tr() would hit Provider's "listen from
  // outside the widget tree" assertion here).
  String _periodTypeLabel(BuildContext context) {
    switch (_periodType) {
      case _PeriodType.weekly:
        return context.trs('period_weekly');
      case _PeriodType.monthly:
        return context.trs('period_monthly');
      case _PeriodType.yearly:
        return context.trs('period_yearly');
    }
  }

  Future<void> _downloadPdf({
    required String periodLabel,
    required double total,
    required int recipientCount,
    required Map<String, ({int count, double total})> byCardType,
    required Map<String, List<Distribution>> recordsByCardType,
  }) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final bytes = await buildDistributionReportPdf(
        periodTypeLabel: _periodTypeLabel(context),
        periodLabel: periodLabel,
        total: total,
        recipientCount: recipientCount,
        byCardType: byCardType,
        recordsByCardType: recordsByCardType,
      );
      final fileName =
          'distribution_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
      final saved = await Printing.sharePdf(bytes: bytes, filename: fileName);
      if (!mounted) return;
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.trs('pdf_share_cancelled'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trsp('pdf_generation_failed', {'error': '$e'})),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final cardTypes = context.watch<ApplicationProvider>().cardTypes;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(context.tr('report_by_card_type')),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(context.tr('report_by_period')),
                ),
              ],
              selected: {_viewByPeriod},
              onSelectionChanged: (s) => setState(() {
                _viewByPeriod = s.first;
                _selectedCardTypeName = null;
              }),
            ),
          ),
          Expanded(
            child: provider.isLoadingDistributions
                ? const Center(child: CircularProgressIndicator())
                : provider.distributionsError != null
                ? ErrorMessage(
                    message: provider.distributionsError!,
                    onRetry: () => provider.loadDistributions(),
                  )
                : _viewByPeriod
                ? _buildPeriodReport(provider)
                : _selectedCardTypeName == null
                ? _buildCardTypeSummary(provider, cardTypes)
                : _buildCardTypeDetail(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodReport(AdminProvider provider) {
    final range = _periodRange(_periodOffset);
    final records =
        provider.distributions
            .where(
              (d) =>
                  !d.distributionDate.isBefore(range.start) &&
                  d.distributionDate.isBefore(range.end),
            )
            .toList()
          ..sort((a, b) => b.distributionDate.compareTo(a.distributionDate));
    final total = records.fold<double>(0, (sum, d) => sum + d.amount);

    final byCardType = <String, ({int count, double total})>{};
    final recordsByCardType = <String, List<Distribution>>{};
    for (final dist in records) {
      final key = dist.cardTypeName ?? '-';
      final existing = byCardType[key] ?? (count: 0, total: 0.0);
      byCardType[key] = (
        count: existing.count + 1,
        total: existing.total + dist.amount,
      );
      recordsByCardType.putIfAbsent(key, () => []).add(dist);
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadDistributions(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<_PeriodType>(
            segments: [
              ButtonSegment(
                value: _PeriodType.weekly,
                label: Text(context.tr('period_weekly')),
              ),
              ButtonSegment(
                value: _PeriodType.monthly,
                label: Text(context.tr('period_monthly')),
              ),
              ButtonSegment(
                value: _PeriodType.yearly,
                label: Text(context.tr('period_yearly')),
              ),
            ],
            selected: {_periodType},
            onSelectionChanged: (s) => setState(() {
              _periodType = s.first;
              _periodOffset = 0;
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => setState(() => _periodOffset -= 1),
              ),
              Text(
                range.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _periodOffset >= 0
                    ? null
                    : () => setState(() => _periodOffset += 1),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: (_isGeneratingPdf || records.isEmpty)
                  ? null
                  : () => _downloadPdf(
                      periodLabel: range.label,
                      total: total,
                      recipientCount: records.length,
                      byCardType: byCardType,
                      recordsByCardType: recordsByCardType,
                    ),
              icon: _isGeneratingPdf
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded),
              label: Text(context.tr('download_pdf_action')),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: AppTheme.primaryGreen.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '৳${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        Text(
                          context.tr('stat_total_disbursed'),
                          style: const TextStyle(
                            fontSize: 12,
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
                        '${records.length}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        context.tr('recipients_label'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (byCardType.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              context.tr('breakdown_by_card_type_label'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: byCardType.entries
                    .map(
                      (entry) => ListTile(
                        dense: true,
                        title: Text(entry.key),
                        trailing: Text(
                          '৳${entry.value.total.toStringAsFixed(0)} (${entry.value.count})',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            context.tr('details_label'),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: EmptyListMessage(
                message: context.tr('no_distribution_records'),
                icon: Icons.receipt_long,
              ),
            )
          else
            for (final entry in recordsByCardType.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              ...entry.value.map(
                (dist) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    title: Text(
                      '${dist.citizenName ?? 'Citizen'} — ৳${dist.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(dist.distributionDate),
                    ),
                  ),
                ),
              ),
            ],
        ],
      ),
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
        .where((d) => d.cardTypeName == cardTypeName)
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
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        title: Text(
                          '${dist.citizenName ?? 'Citizen'} — ৳${dist.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(dist.distributionDate),
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
