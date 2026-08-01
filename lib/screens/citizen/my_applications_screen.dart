import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/screens/citizen/document_upload_screen.dart';
import 'package:onecitizen/utils/apply_card_navigation.dart';
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

String _statusLabel(BuildContext context, ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.submitted:
      return context.tr('status_submitted');
    case ApplicationStatus.underReview:
      return context.tr('status_under_review');
    case ApplicationStatus.approved:
      return context.tr('stat_approved');
    case ApplicationStatus.rejected:
      return context.tr('stat_rejected');
  }
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
      appBar: AppBar(title: Text(context.tr('my_applications_title'))),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(
                  label: context.tr('filter_all'),
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                ...ApplicationStatus.values.map(
                  (s) => _FilterChip(
                    label: _statusLabel(context, s),
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
                  ? ErrorMessage(
                      message: appProvider.error!,
                      onRetry: () => appProvider.loadApplications(),
                    )
                  : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 60,
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _filter == null
                                ? context.tr('no_applications_submitted_yet')
                                : context.tr('no_applications_with_status'),
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (_filter == null) ...[
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => goToApplyCard(context),
                              child: Text(
                                context.tr('apply_for_new_card_action'),
                              ),
                            ),
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
                              child: Icon(
                                Icons.assignment_rounded,
                                color: color,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              application.cardTypeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              context.trp('submitted_date_prefix', {
                                'date': DateFormat(
                                  'dd MMM yyyy',
                                ).format(application.submittedAt),
                              }),
                            ),
                            trailing: StatusBadge(
                              label: _statusLabel(context, application.status),
                              color: color,
                            ),
                            onTap: () => context.push(
                              '/citizen/applications/${application.id}',
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      context.read<ApplicationProvider>().loadApplicationById(
        widget.applicationId,
      );
      context.read<ApplicationProvider>().loadCardTypes();
      context.read<ApplicationProvider>().loadDocuments();
    });
  }

  List<String> _requiredDocumentsFor(
    Application application,
    ApplicationProvider provider,
  ) {
    for (final cardType in provider.cardTypes) {
      if (cardType.id == application.cardTypeId) {
        return cardType.requiredDocuments;
      }
    }

    return provider.documents
        .map((document) => document.docType)
        .toSet()
        .toList();
  }

  CitizenDocument? _documentFor(
    String applicationId,
    String docType,
    List<CitizenDocument> documents,
  ) {
    for (final document in documents) {
      if (document.applicationId == applicationId && document.docType == docType) {
        return document;
      }
    }
    return null;
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
        appBar: AppBar(title: Text(context.tr('application_details_title'))),
        body: Center(
          child: Text(
            appProvider.detailError ?? context.tr('application_not_found'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('application_details_title'))),
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      StatusBadge(
                        label: _statusLabel(context, application.status),
                        color: statusColor(application.status),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    context.trp('application_id_prefix', {
                      'id': application.id,
                    }),
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.trp('submitted_on_prefix', {
                      'date': DateFormat(
                        'dd MMM yyyy',
                      ).format(application.submittedAt),
                    }),
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  if (application.updatedAt != null)
                    Text(
                      context.trp('last_updated_prefix', {
                        'date': DateFormat(
                          'dd MMM yyyy',
                        ).format(application.updatedAt!),
                      }),
                    ),
                  if (application.adminRemark != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              application.adminRemark!,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
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
            const SizedBox(height: 24),
            Text(
              context.tr('document_validation_status_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_requiredDocumentsFor(application, appProvider).isEmpty)
              Text(context.tr('no_documents_uploaded_yet'))
            else
              ..._requiredDocumentsFor(application, appProvider).map((docType) {
                final document = _documentFor(
                  application.id,
                  docType,
                  appProvider.documents,
                );
                return _DocumentValidationTile(
                  applicationStatus: application.status,
                  docType: docType,
                  document: document,
                  applicationId: application.id,
                  cardTypeName: application.cardTypeName,
                  requiredDocuments: _requiredDocumentsFor(
                    application,
                    appProvider,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DocumentValidationTile extends StatelessWidget {
  const _DocumentValidationTile({
    required this.applicationStatus,
    required this.docType,
    required this.document,
    required this.applicationId,
    required this.cardTypeName,
    required this.requiredDocuments,
  });

  final ApplicationStatus applicationStatus;
  final String docType;
  final CitizenDocument? document;
  final String applicationId;
  final String cardTypeName;
  final List<String> requiredDocuments;

  _DocumentValidationState _state(BuildContext context) {
    switch (applicationStatus) {
      case ApplicationStatus.submitted:
        return _DocumentValidationState(
          label: context.tr('status_submitted'),
          helperText: null,
          icon: Icons.upload_file_rounded,
          color: AppTheme.infoBlue,
        );
      case ApplicationStatus.underReview:
        return _DocumentValidationState(
          label: context.tr('status_pending'),
          helperText: null,
          icon: Icons.hourglass_top_rounded,
          color: AppTheme.warningAmber,
        );
      case ApplicationStatus.approved:
        return _DocumentValidationState(
          label: context.tr('stat_approved'),
          helperText: null,
          icon: Icons.check_circle_rounded,
          color: AppTheme.successGreen,
        );
      case ApplicationStatus.rejected:
        if (document?.isValid == false) {
          return _DocumentValidationState(
            label: context.tr('stat_rejected'),
            helperText: document?.remark?.trim().isNotEmpty == true
                ? document!.remark
                : context.tr('please_resubmit_document'),
            icon: Icons.cancel_rounded,
            color: AppTheme.errorRed,
          );
        }
        if (document?.isValid == true) {
          return _DocumentValidationState(
            label: context.tr('stat_approved'),
            helperText: null,
            icon: Icons.check_circle_rounded,
            color: AppTheme.successGreen,
          );
        }
        return _DocumentValidationState(
          label: context.tr('status_resubmit'),
          helperText: context.tr('please_resubmit_document'),
          icon: Icons.refresh_rounded,
          color: AppTheme.errorRed,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: state.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(state.icon, color: state.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentTypeLabel(docType),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (state.helperText != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      state.helperText!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 110),
                  child: StatusBadge(label: state.label, color: state.color),
                ),
                if (document?.isValid == false) ...[
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: () => context.push(
                      '/citizen/documents',
                      extra: DocumentUploadArgs(
                        applicationId: applicationId,
                        cardTypeName: cardTypeName,
                        requiredDocuments: requiredDocuments,
                      ),
                    ),
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: Text(context.tr('reupload_action')),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentValidationState {
  const _DocumentValidationState({
    required this.label,
    required this.helperText,
    required this.icon,
    required this.color,
  });

  final String label;
  final String? helperText;
  final IconData icon;
  final Color color;
}
