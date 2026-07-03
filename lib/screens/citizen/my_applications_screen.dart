import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

Color statusColor(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.approved:
      return Colors.green;
    case ApplicationStatus.rejected:
      return Colors.red;
    case ApplicationStatus.underReview:
      return Colors.blue;
    case ApplicationStatus.submitted:
      return AppTheme.primaryGreen;
  }
}

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  ApplicationStatus? _filter;

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
    final filtered = _filter == null
        ? appProvider.applications
        : appProvider.applications.where((a) => a.status == _filter).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('My Applications')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                ...ApplicationStatus.values.map(
                  (s) => _FilterChip(
                    label: applicationStatusToString(s),
                    selected: _filter == s,
                    onTap: () => setState(() => _filter = s),
                    color: statusColor(s),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => appProvider.loadApplications(),
              child: appProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : appProvider.error != null
                      ? ErrorMessage(message: appProvider.error!, onRetry: () => appProvider.loadApplications())
                      : filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history, size: 60, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    _filter == null ? 'No applications submitted yet.' : 'No applications with this status.',
                                    style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
                                  ),
                                  if (_filter == null) ...[
                                    const SizedBox(height: 12),
                                    ElevatedButton(onPressed: () => context.push('/citizen/apply'), child: const Text('Apply for a new card')),
                                  ],
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final application = filtered[index];
                                final color = statusColor(application.status);
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.assignment_rounded, color: color, size: 22),
                                    ),
                                    title: Text(application.cardTypeName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    subtitle: Text('Submitted: ${DateFormat('dd MMM yyyy').format(application.submittedAt)}'),
                                    trailing: StatusBadge(label: application.status.name, color: color),
                                    onTap: () => context.push('/citizen/applications/${application.id}'),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color});

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
          style: TextStyle(color: selected ? Colors.white : chipColor, fontWeight: FontWeight.w600, fontSize: 12),
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

class ApplicationDetailScreen extends StatefulWidget {
  const ApplicationDetailScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadApplicationById(widget.applicationId);
      context.read<ApplicationProvider>().loadDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();
    final application = appProvider.selectedApplication;

    if (appProvider.isLoadingDetail) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Details')),
        body: Center(child: Text(appProvider.detailError ?? 'Application not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Application Details')),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          application.cardTypeName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                      ),
                      StatusBadge(label: application.status.name, color: statusColor(application.status)),
                    ],
                  ),
                  const Divider(height: 24),
                  Text('Application ID: ${application.id}', style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text('Submitted On: ${DateFormat('dd MMM yyyy').format(application.submittedAt)}', style: const TextStyle(color: AppTheme.textSecondary)),
                  if (application.updatedAt != null)
                    Text('Last Updated: ${DateFormat('dd MMM yyyy').format(application.updatedAt!)}'),
                  if (application.adminRemark != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(application.adminRemark!, style: const TextStyle(fontStyle: FontStyle.italic))),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Document Validation Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (appProvider.documents.isEmpty)
              const Text('No documents uploaded yet.')
            else
              ...appProvider.documents.map((doc) {
                final color = doc.isValid == true
                    ? AppTheme.successGreen
                    : doc.isValid == false
                        ? AppTheme.errorRed
                        : AppTheme.warningAmber;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        doc.isValid == true
                            ? Icons.check_circle_rounded
                            : doc.isValid == false
                                ? Icons.cancel_rounded
                                : Icons.hourglass_top_rounded,
                        color: color,
                        size: 20,
                      ),
                    ),
                    title: Text(documentTypeLabel(doc.docType), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: doc.remark != null ? Text(doc.remark!) : null,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
