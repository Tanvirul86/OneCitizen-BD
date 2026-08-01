import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:provider/provider.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key, this.args});

  final DocumentUploadArgs? args;

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final Set<String> _uploading = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadDocuments();
    });
  }

  Future<void> _upload(String docType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
    if (!mounted) return;

    final appProvider = context.read<ApplicationProvider>();
    setState(() => _uploading.add(docType));
      final success = await appProvider.uploadDocument(
        docType: docType,
        filePath: result.files.single.path!,
        applicationId: widget.args?.applicationId,
    );
    if (!mounted) return;
    setState(() => _uploading.remove(docType));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.trs('document_uploaded_success')
              : context.trs('upload_failed_retry'),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();
    final scopedDocuments = appProvider.documents
        .where((document) => document.applicationId == widget.args?.applicationId)
        .toList();
    final byType = {for (final d in scopedDocuments) d.docType: d};
    final documentTypes = widget.args?.requiredDocuments ?? requiredDocumentTypes;
    final uploaded = scopedDocuments.length;
    final total = documentTypes.length;
    final valid = scopedDocuments.where((d) => d.isValid == true).length;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: Text(
          widget.args == null
              ? context.tr('document_upload_title')
              : context.trp('card_documents_title', {
                  'name': widget.args!.cardTypeName,
                }),
        ),
      ),
      body: appProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => appProvider.loadDocuments(),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Progress summary card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('document_progress_title'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ProgressStat(value: '$uploaded/$total', label: context.tr('uploaded_label')),
                            const SizedBox(width: 24),
                            _ProgressStat(value: '$valid', label: context.tr('verified_label')),
                            const SizedBox(width: 24),
                            _ProgressStat(
                              value: '${total - uploaded}',
                              label: context.tr('status_pending'),
                              highlight: (total - uploaded) > 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total > 0 ? uploaded / total : 0,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            color: Colors.white,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('accepted_formats_hint'),
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...documentTypes.map((docType) {
                    final doc = byType[docType];
                    final isUploading = _uploading.contains(docType);
                    return _DocumentCard(
                      docType: docType,
                      document: doc,
                      isUploading: isUploading,
                      onUpload: () => _upload(docType),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class DocumentUploadArgs {
  const DocumentUploadArgs({
    required this.applicationId,
    required this.cardTypeName,
    required this.requiredDocuments,
  });

  final String applicationId;
  final String cardTypeName;
  final List<String> requiredDocuments;
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.value, required this.label, this.highlight = false});
  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: highlight ? Colors.orange.shade200 : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.docType,
    required this.document,
    required this.isUploading,
    required this.onUpload,
  });

  final String docType;
  final CitizenDocument? document;
  final bool isUploading;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final isValid = document?.isValid;
    final isUploaded = document != null;
    final isInvalid = isValid == false;
    final isPending = isUploaded && isValid == null;

    Color borderColor;
    Color iconBg;
    Color iconColor;
    IconData statusIcon;
    String statusText;
    String statusSubtext;

    if (!isUploaded) {
      borderColor = AppTheme.divider;
      iconBg = AppTheme.surfaceLight;
      iconColor = AppTheme.textSecondary;
      statusIcon = Icons.upload_file_rounded;
      statusText = context.tr('status_not_uploaded');
      statusSubtext = context.tr('tap_upload_hint');
    } else if (isPending) {
      borderColor = Colors.orange.withValues(alpha: 0.5);
      iconBg = Colors.orange.withValues(alpha: 0.1);
      iconColor = Colors.orange;
      statusIcon = Icons.hourglass_top_rounded;
      statusText = context.tr('status_pending_review');
      statusSubtext = context.tr('pending_review_subtext');
    } else if (isValid == true) {
      borderColor = Colors.green.withValues(alpha: 0.5);
      iconBg = Colors.green.withValues(alpha: 0.1);
      iconColor = Colors.green;
      statusIcon = Icons.check_circle_rounded;
      statusText = context.tr('verified_label');
      statusSubtext = context.tr('document_accepted_subtext');
    } else {
      borderColor = Colors.red.withValues(alpha: 0.5);
      iconBg = Colors.red.withValues(alpha: 0.1);
      iconColor = Colors.red;
      statusIcon = Icons.cancel_rounded;
      statusText = context.tr('invalid_action');
      statusSubtext =
          document?.remark ?? context.tr('please_reupload_valid_document');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(statusIcon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documentTypeLabel(docType),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                      if (statusSubtext.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          statusSubtext,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(13),
                bottomRight: Radius.circular(13),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                if (isUploaded && document?.fileUrl != null) ...[
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.trs('opening_document_preview')),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text(context.tr('view_action'), style: const TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                const Spacer(),
                if (isUploading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  FilledButton.icon(
                    onPressed: onUpload,
                    icon: Icon(isUploaded ? Icons.upload_rounded : Icons.add_rounded, size: 16),
                    label: Text(
                      isInvalid
                          ? context.tr('reupload_action')
                          : isUploaded
                              ? context.tr('replace_action')
                              : context.tr('upload_action'),
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: isInvalid ? Colors.red : AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
