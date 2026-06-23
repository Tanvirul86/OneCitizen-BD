import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/widgets/application_timeline.dart';
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _openDocument(BuildContext context, ApplicationDocument doc) async {
  if (doc.url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document URL not available')),
    );
    return;
  }
  final uri = Uri.tryParse(doc.url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open document: ${doc.name}')),
      );
    }
  }
}

Color _statusColor(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.approved:
      return Colors.green;
    case ApplicationStatus.rejected:
      return Colors.red;
    case ApplicationStatus.documentRequested:
      return Colors.orange;
    case ApplicationStatus.underReview:
      return Colors.blue;
    case ApplicationStatus.submitted:
      return AppTheme.primaryGreen;
  }
}

class ApplicationTrackerScreen extends StatefulWidget {
  const ApplicationTrackerScreen({super.key});

  @override
  State<ApplicationTrackerScreen> createState() =>
      _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Application Tracker'),
      ),
      body: RefreshIndicator(
        onRefresh: () => appProvider.loadApplications(),
        child: appProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : appProvider.applications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 60,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No applications submitted yet.',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.push('/citizen/apply'),
                          child: const Text('Apply for a new card'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appProvider.applications.length,
                    itemBuilder: (context, index) {
                      final application = appProvider.applications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(application.cardTypeName),
                          subtitle: Text(
                              'Submitted: ${DateFormat('dd MMM yyyy').format(application.createdAt)}'),
                          trailing: StatusBadge(
                            label: application.status.name,
                            color: _statusColor(application.status),
                          ),
                          onTap: () => context
                              .push('/citizen/tracker/${application.id}'),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class ApplicationDetailScreen extends StatefulWidget {
  const ApplicationDetailScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ApplicationProvider>()
          .loadApplicationById(widget.applicationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();
    final application = appProvider.selectedApplication;

    if (appProvider.isLoadingDetail) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Details')),
        body: Center(
          child: Text(
            appProvider.detailError ?? 'Application not found.',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
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
                        StatusBadge(
                          label: application.status.name,
                          color: _statusColor(application.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Application ID: ${application.id}'),
                    const SizedBox(height: 4),
                    Text(
                      'Submitted On: ${DateFormat('dd MMM yyyy').format(application.createdAt)}',
                    ),
                    if (application.updatedAt != null)
                      Text(
                        'Last Updated: ${DateFormat('dd MMM yyyy').format(application.updatedAt!)}',
                      ),
                    if (application.remarks != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Remarks: ${application.remarks}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
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
                    onTap: () => _openDocument(context, doc),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
