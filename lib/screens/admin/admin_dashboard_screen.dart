import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/providers/admin_notification_provider.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/screens/admin/new_applications_screen.dart';
import 'package:onecitizen/screens/citizen/my_applications_screen.dart'
    show statusColor;
import 'package:onecitizen/services/seed_service.dart';
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
      context.read<AdminNotificationProvider>().loadNotifications();
      // Best-effort: brings card_types up to the current schema (dynamic
      // application fields, disbursement amount) for databases seeded
      // before those existed. No-op once the data already matches.
      ensureCardTypesUpToDate().catchError((_) {});
      // Best-effort: links any document uploaded after its application was
      // already submitted, so it isn't stuck invisible to review.
      relinkOrphanedDocuments().catchError((_) {});
    });
  }

  Future<void> _refresh() async {
    final provider = context.read<AdminProvider>();
    await Future.wait([provider.loadAnalytics(), provider.loadApplications()]);
  }

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('greeting_morning');
    if (hour < 17) return context.tr('greeting_afternoon');
    return context.tr('greeting_evening');
  }

  String _statusLabel(BuildContext context, ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
      case ApplicationStatus.underReview:
        return context.tr('status_under_review');
      case ApplicationStatus.approved:
        return context.tr('stat_approved');
      case ApplicationStatus.rejected:
        return context.tr('stat_rejected');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final user = context.watch<AuthProvider>().user;
    final analytics = provider.analytics ?? {};
    final recentApplications = provider.applications.take(4).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: provider.isLoadingAnalytics && provider.analytics == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppTheme.primaryGreen,
              onRefresh: _refresh,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.heroGradient,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(context),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user?.fullName.isNotEmpty == true
                                    ? user!.fullName
                                    : context.tr('administrator'),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              tooltip: context.tr('admin_nav_new_applications'),
                              onPressed: () =>
                                  context.go('/admin/applications'),
                              icon: const Icon(Icons.assignment_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.14,
                                ),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _HeroStat(
                                label: context.tr('hero_pending_applications'),
                                value: '${analytics['pending_review'] ?? 0}',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 34,
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                            Expanded(
                              child: _HeroStat(
                                label: context.tr('hero_docs_to_review'),
                                value:
                                    '${analytics['pending_document_reviews'] ?? 0}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.55,
                              ),
                          children: [
                            _MetricTile(
                              label: context.tr('stat_total_applications'),
                              value: '${analytics['total_applications'] ?? 0}',
                              icon: Icons.assignment_rounded,
                              color: AppTheme.primaryGreen,
                              onTap: () => context.go('/admin/applications'),
                            ),
                            _MetricTile(
                              label: context.tr('stat_pending_review'),
                              value: '${analytics['pending_review'] ?? 0}',
                              icon: Icons.pending_actions_rounded,
                              color: AppTheme.warningAmber,
                              onTap: () => context.go(
                                '/admin/applications',
                                extra: ApplicationsFilterArgs(
                                  statuses: const [
                                    ApplicationStatus.submitted,
                                    ApplicationStatus.underReview,
                                  ],
                                  scopeLabel: context.trs(
                                    'stat_pending_review',
                                  ),
                                ),
                              ),
                            ),
                            _MetricTile(
                              label: context.tr('stat_approved'),
                              value: '${analytics['approved'] ?? 0}',
                              icon: Icons.verified_rounded,
                              color: AppTheme.successGreen,
                              onTap: () => context.go(
                                '/admin/applications',
                                extra: ApplicationsFilterArgs(
                                  statuses: const [ApplicationStatus.approved],
                                  scopeLabel: context.trs('stat_approved'),
                                ),
                              ),
                            ),
                            _MetricTile(
                              label: context.tr('stat_rejected'),
                              value: '${analytics['rejected'] ?? 0}',
                              icon: Icons.cancel_rounded,
                              color: AppTheme.errorRed,
                              onTap: () => context.go(
                                '/admin/applications',
                                extra: ApplicationsFilterArgs(
                                  statuses: const [ApplicationStatus.rejected],
                                  scopeLabel: context.trs('stat_rejected'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _SectionHeader(
                          title: context.tr('admin_nav_new_applications'),
                          actionLabel: context.tr('filter_all'),
                          onAction: () => context.go('/admin/applications'),
                        ),
                        const SizedBox(height: 10),
                        if (provider.isLoadingApplications &&
                            recentApplications.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (recentApplications.isEmpty)
                          _EmptyPanel(
                            message: context.tr('no_applications_found'),
                          )
                        else
                          ...recentApplications.map(
                            (application) => _RecentApplicationTile(
                              application: application,
                              statusLabel: _statusLabel(
                                context,
                                application.status,
                              ),
                              onTap: () => context.push(
                                '/admin/applications/${application.id}',
                              ),
                            ),
                          ),
                        const SizedBox(height: 18),
                        Text(
                          context.tr('quick_actions_title'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ActionRow(
                          icon: Icons.assignment_rounded,
                          title: context.tr('admin_nav_new_applications'),
                          subtitle: context.tr('action_review_decide'),
                          color: AppTheme.primaryGreen,
                          onTap: () => context.go('/admin/applications'),
                        ),
                        _ActionRow(
                          icon: Icons.fact_check_rounded,
                          title: context.tr('admin_nav_document_validation'),
                          subtitle: context.tr('action_verify_uploads'),
                          color: AppTheme.infoBlue,
                          onTap: () => context.go('/admin/documents'),
                        ),
                        _ActionRow(
                          icon: Icons.credit_card_rounded,
                          title: context.tr('admin_nav_approved_cards'),
                          subtitle: context.tr('action_view_issued_cards'),
                          color: AppTheme.successGreen,
                          onTap: () => context.go('/admin/approved-cards'),
                        ),
                        _ActionRow(
                          icon: Icons.payments_rounded,
                          title: context.tr('admin_nav_fund_distribution'),
                          subtitle: context.tr('action_disburse_funds'),
                          color: AppTheme.warningAmber,
                          onTap: () => context.go('/admin/distributions/new'),
                        ),
                        _ActionRow(
                          icon: Icons.receipt_long_rounded,
                          title: context.tr('admin_nav_distribution_records'),
                          subtitle: context.tr('action_disbursement_history'),
                          color: AppTheme.accentRed,
                          onTap: () => context.go('/admin/distributions'),
                        ),
                        _ActionRow(
                          icon: Icons.people_rounded,
                          title: context.tr('admin_nav_citizen_accounts'),
                          subtitle: context.tr('action_manage_citizens'),
                          color: AppTheme.primaryGreenDark,
                          onTap: () => context.go('/admin/citizens'),
                        ),
                        _ActionRow(
                          icon: Icons.bar_chart_rounded,
                          title: context.tr('admin_nav_analytics'),
                          subtitle: context.tr('action_program_insights'),
                          color: AppTheme.textPrimary,
                          onTap: () => context.go('/admin/analytics'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _RecentApplicationTile extends StatelessWidget {
  const _RecentApplicationTile({
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.assignment_rounded, color: color, size: 20),
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
                      '${application.cardTypeName} - ${DateFormat('dd MMM yyyy').format(application.submittedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(label: statusLabel, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
