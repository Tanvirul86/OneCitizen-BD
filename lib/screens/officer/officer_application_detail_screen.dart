import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/providers/officer_provider.dart';
import 'package:onecitizen/widgets/application_timeline.dart';
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OfficerApplicationDetailScreen extends StatefulWidget {
  const OfficerApplicationDetailScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  State<OfficerApplicationDetailScreen> createState() =>
      _OfficerApplicationDetailScreenState();
}

class _OfficerApplicationDetailScreenState
    extends State<OfficerApplicationDetailScreen> {
  final _remarksController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<OfficerProvider>()
          .loadApplicationDetail(widget.applicationId);
    });
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(ApplicationStatus status) async {
    setState(() => _isLoading = true);
    final officerProvider = context.read<OfficerProvider>();

    try {
      final success = await officerProvider.updateStatus(
        id: widget.applicationId,
        status: status,
        remarks: _remarksController.text.trim(),
      );
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Application ${applicationStatusToString(status)} successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(officerProvider.error ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyNid(String nid) async {
    setState(() => _isLoading = true);
    final officerProvider = context.read<OfficerProvider>();

    try {
      await officerProvider.verifyCitizen(nid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              officerProvider.verificationResult?[
                      'is_verified'] ==
                  true
                  ? 'NID Verified Successfully!'
                  : 'NID Verification Failed.',
            ),
            backgroundColor: officerProvider.verificationResult?[
                    'is_verified'] ==
                true
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(officerProvider.error ?? 'Failed to verify NID'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final officerProvider = context.watch<OfficerProvider>();
    final application = officerProvider.selectedApplication;

    if (officerProvider.isLoading && application == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Details')),
        body: Center(
          child: Text(
            officerProvider.error ?? 'Application not found.',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('Application Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.cardTypeName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status: '),
                        StatusBadge(status: application.status.name),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Applicant: ${application.applicantName ?? 'N/A'}'),
                    Text('NID: ${application.applicantNid ?? 'N/A'}'),
                    Text('Phone: ${application.applicantPhone ?? 'N/A'}'),
                    const SizedBox(height: 8),
                    Text(
                        'Submitted On: ${DateFormat('dd MMM yyyy HH:mm').format(application.createdAt)}'),
                    if (application.updatedAt != null)
                      Text(
                          'Last Updated: ${DateFormat('dd MMM yyyy HH:mm').format(application.updatedAt!)}'),
                    if (application.remarks != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Remarks: ${application.remarks}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (application.applicantNid != null)
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _verifyNid(application.applicantNid!),
                        icon: const Icon(Icons.verified_user),
                        label: const Text('Verify NID'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                      ),
                    if (officerProvider.verificationResult != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Verification Result: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Status: ${officerProvider.verificationResult?['is_verified'] == true ? 'Verified' : 'Not Verified'}'
                            '${officerProvider.verificationResult?['message'] != null ? ' - ${officerProvider.verificationResult!['message']}' : ''}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Application Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ApplicationTimeline(timeline: application.timeline),
            const SizedBox(height: 24),
            const Text(
              'Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (application.documents.isEmpty)
              const Text('No documents attached.')
            else
              ...application.documents.map(
                (doc) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(doc.name),
                    subtitle: Text(doc.documentType ?? 'General'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () async {
                      if (doc.url.isEmpty) return;
                      final uri = Uri.tryParse(doc.url);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Cannot open: ${doc.name}')),
                        );
                      }
                    },
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (application.status == ApplicationStatus.submitted ||
                application.status == ApplicationStatus.underReview ||
                application.status == ApplicationStatus.documentRequested) ...[
              const Text(
                'Officer Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (Optional)',
                  hintText: 'Add notes for the applicant or other officers',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _updateStatus(ApplicationStatus.approved),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _updateStatus(ApplicationStatus.rejected),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (application.status != ApplicationStatus.documentRequested)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _updateStatus(ApplicationStatus.documentRequested),
                    icon: const Icon(Icons.replay_outlined),
                    label: const Text('Request More Documents'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
