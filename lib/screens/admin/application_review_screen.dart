import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/screens/admin/document_validation_screen.dart';
import 'package:onecitizen/screens/citizen/my_applications_screen.dart'
    show statusColor;
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

class ApplicationReviewScreen extends StatefulWidget {
  const ApplicationReviewScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  State<ApplicationReviewScreen> createState() =>
      _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  bool _isSubmitting = false;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadApplicationDetail(widget.applicationId);
    });
  }

  Future<void> _approve() async {
    setState(() => _isSubmitting = true);
    final provider = context.read<AdminProvider>();
    final success = await provider.approveApplication(widget.applicationId);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.trs('application_approved')
              : provider.applicationsError ?? context.trs('failed'),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _reject() async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.trs('reject_application_title')),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            decoration: InputDecoration(labelText: context.trs('reason_label')),
            maxLines: 3,
            validator: (v) => (v == null || v.isEmpty)
                ? context.trs('reason_required')
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.trs('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.trs('reject_action')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isSubmitting = true);
    final provider = context.read<AdminProvider>();
    final success = await provider.rejectApplication(
      widget.applicationId,
      reason: reasonController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.trs('application_rejected')
              : provider.applicationsError ?? context.trs('failed'),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final app = provider.selectedApplication;

    if (provider.isLoadingApplications && app == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (app == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('application_review_title'))),
        body: Center(
          child: Text(
            provider.applicationsError ?? context.tr('application_not_found'),
          ),
        ),
      );
    }

    final isPending =
        app.status.name == 'submitted' || app.status.name == 'underReview';

    final color = statusColor(app.status);
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: Text(context.tr('application_review_title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.assignment_rounded,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          app.cardTypeName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      StatusBadge(
                        label: _statusLabel(context, app.status),
                        color: color,
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: context.tr('applicant_label'),
                    value: app.applicantName ?? '-',
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: context.tr('nid_short_label'),
                    value: app.applicantNid ?? '-',
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.email_outlined,
                    label: context.tr('email_short_label'),
                    value: app.applicantEmail ?? '-',
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.event_outlined,
                    label: context.tr('request_received_label'),
                    value: DateFormat('dd MMM yyyy').format(app.submittedAt),
                  ),
                  if (app.adminRemark != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warningAmber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.warningAmber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppTheme.warningAmber,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              app.adminRemark!,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push(
                '/admin/documents',
                extra: DocumentValidationFilterArgs(
                  citizenId: app.applicantId,
                  citizenEmail: app.applicantEmail,
                  citizenName: app.applicantName,
                ),
              ),
              icon: const Icon(Icons.fact_check_rounded),
              label: Text(context.tr('review_citizen_documents')),
            ),
            if (isPending) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _reject,
                      icon: const Icon(Icons.close_rounded),
                      label: Text(context.tr('reject_action')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _approve,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(context.tr('approve_action')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppTheme.textTertiary),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
