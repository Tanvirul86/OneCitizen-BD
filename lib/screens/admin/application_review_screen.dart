import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/screens/citizen/my_applications_screen.dart' show statusColor;
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

class ApplicationReviewScreen extends StatefulWidget {
  const ApplicationReviewScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  State<ApplicationReviewScreen> createState() => _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  bool _isSubmitting = false;

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
      SnackBar(content: Text(success ? 'Application approved' : provider.applicationsError ?? 'Failed'), backgroundColor: success ? Colors.green : Colors.red),
    );
  }

  Future<void> _reject() async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: 'Reason'),
            maxLines: 3,
            validator: (v) => (v == null || v.isEmpty) ? 'A reason is required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isSubmitting = true);
    final provider = context.read<AdminProvider>();
    final success = await provider.rejectApplication(widget.applicationId, reason: reasonController.text.trim());
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Application rejected' : provider.applicationsError ?? 'Failed'), backgroundColor: success ? Colors.green : Colors.red),
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
        appBar: AppBar(title: const Text('Application Review')),
        body: Center(child: Text(provider.applicationsError ?? 'Application not found.')),
      );
    }

    final isPending = app.status.name == 'submitted' || app.status.name == 'underReview';

    final color = statusColor(app.status);
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('Application Review')),
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
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.assignment_rounded, color: color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(app.cardTypeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                      ),
                      StatusBadge(label: app.status.name, color: color),
                    ],
                  ),
                  const Divider(height: 28),
                  _DetailRow(icon: Icons.person_outline_rounded, label: 'Applicant', value: app.applicantName ?? '-'),
                  const SizedBox(height: 10),
                  _DetailRow(icon: Icons.badge_outlined, label: 'NID', value: app.applicantNid ?? '-'),
                  const SizedBox(height: 10),
                  _DetailRow(icon: Icons.email_outlined, label: 'Email', value: app.applicantEmail ?? '-'),
                  const SizedBox(height: 10),
                  _DetailRow(icon: Icons.event_outlined, label: 'Submitted', value: DateFormat('dd MMM yyyy').format(app.submittedAt)),
                  if (app.adminRemark != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warningAmber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTheme.warningAmber, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(app.adminRemark!, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13))),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push('/admin/documents'),
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('Review Citizen Documents'),
            ),
            if (isPending) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _reject,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorRed, side: const BorderSide(color: AppTheme.errorRed)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _approve,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
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
  const _DetailRow({required this.icon, required this.label, required this.value});
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
          child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ),
      ],
    );
  }
}
