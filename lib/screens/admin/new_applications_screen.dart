import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/screens/citizen/my_applications_screen.dart'
    show statusColor;
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

String _statusLabel(BuildContext context, ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.submitted:
      return context.tr('status_request');
    case ApplicationStatus.underReview:
      return context.tr('status_under_review');
    case ApplicationStatus.approved:
      return context.tr('stat_approved');
    case ApplicationStatus.rejected:
      return context.tr('stat_rejected');
  }
}

/// Navigation payload for `/admin/applications`. Callers can scope the list to
/// a card type and/or statuses, for example pending review.
class ApplicationsFilterArgs {
  const ApplicationsFilterArgs({
    this.cardTypeName,
    this.statuses,
    this.scopeLabel,
  });

  final String? cardTypeName;
  final List<ApplicationStatus>? statuses;
  final String? scopeLabel;
}

class NewApplicationsScreen extends StatefulWidget {
  const NewApplicationsScreen({
    super.key,
    this.initialCardTypeName,
    this.initialStatuses,
    this.statusScopeLabel,
  });

  final String? initialCardTypeName;
  final List<ApplicationStatus>? initialStatuses;
  final String? statusScopeLabel;

  @override
  State<NewApplicationsScreen> createState() => _NewApplicationsScreenState();
}

class _NewApplicationsScreenState extends State<NewApplicationsScreen> {
  ApplicationStatus? _filter;
  String? _cardTypeFilter;
  List<ApplicationStatus>? _statusScope;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _cardTypeFilter = widget.initialCardTypeName;
    _statusScope = widget.initialStatuses;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadApplications();
    });
  }

  Future<void> _openApplication(String id) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    await context.push('/admin/applications/$id');
    if (mounted) setState(() => _isNavigating = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final filtered = provider.applications
        .where((a) => _filter == null || a.status == _filter)
        .where(
          (a) => _cardTypeFilter == null || a.cardTypeName == _cardTypeFilter,
        )
        .where((a) => _statusScope == null || _statusScope!.contains(a.status))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: Column(
        children: [
          if (_cardTypeFilter != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _FilterNotice(
                message: context.trp('showing_card_type_applications', {
                  'type': _cardTypeFilter!,
                }),
                onClear: () => setState(() => _cardTypeFilter = null),
              ),
            ),
          if (_statusScope != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _FilterNotice(
                message: context.trp('showing_scoped_applications', {
                  'scope':
                      widget.statusScopeLabel ?? context.trs('filtered_label'),
                }),
                onClear: () => setState(() => _statusScope = null),
              ),
            ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _Chip(
                  label: context.tr('filter_all'),
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                ...ApplicationStatus.values.map(
                  (status) => _Chip(
                    label: _statusLabel(context, status),
                    selected: _filter == status,
                    color: statusColor(status),
                    onTap: () => setState(() => _filter = status),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadApplications(),
              child: provider.isLoadingApplications
                  ? const Center(child: CircularProgressIndicator())
                  : provider.applicationsError != null
                  ? ErrorMessage(
                      message: provider.applicationsError!,
                      onRetry: () => provider.loadApplications(),
                    )
                  : filtered.isEmpty
                  ? EmptyListMessage(
                      message: context.tr('no_applications_found'),
                      icon: Icons.assignment_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final application = filtered[index];
                        return _ApplicationCard(
                          application: application,
                          statusLabel: _statusLabel(
                            context,
                            application.status,
                          ),
                          onTap: () => _openApplication(application.id),
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

class _FilterNotice extends StatelessWidget {
  const _FilterNotice({required this.message, required this.onClear});

  final String message;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_rounded,
            size: 18,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                fontSize: 12.5,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: context.tr('clear'),
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.statusLabel,
    required this.onTap,
  });

  final Application application;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(application.status);
    final applicantName = application.applicantName?.trim().isNotEmpty == true
        ? application.applicantName!.trim()
        : context.tr('applicant_label');
    final nid = application.applicantNid?.trim().isNotEmpty == true
        ? application.applicantNid!.trim()
        : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.assignment_rounded,
                      color: color,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          application.cardTypeName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 118),
                    child: StatusBadge(label: statusLabel, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  _MetaChip(
                    icon: Icons.badge_outlined,
                    text: '${context.tr('nid_short_label')}: $nid',
                  ),
                  _MetaChip(
                    icon: Icons.event_outlined,
                    text: DateFormat(
                      'dd MMM yyyy',
                    ).format(application.submittedAt),
                  ),
                  _MetaChip(icon: Icons.numbers_rounded, text: application.id),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textTertiary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primaryGreen;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label.replaceAll('_', ' '),
          style: TextStyle(
            color: selected ? Colors.white : chipColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: chipColor,
        backgroundColor: chipColor.withValues(alpha: 0.1),
        checkmarkColor: Colors.white,
        side: BorderSide(color: chipColor.withValues(alpha: 0.4)),
        showCheckmark: false,
      ),
    );
  }
}
