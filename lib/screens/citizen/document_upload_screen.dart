import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:provider/provider.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

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
    );
    if (!mounted) return;
    setState(() => _uploading.remove(docType));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Document uploaded successfully' : 'Upload failed. Please try again.'),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();
    final byType = {for (final d in appProvider.documents) d.docType: d};
    final uploaded = appProvider.documents.length;
    final total = requiredDocumentTypes.length;
    final valid = appProvider.documents.where((d) => d.isValid == true).length;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('Document Upload')),
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
                        const Text(
                          'Document Progress',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ProgressStat(value: '$uploaded/$total', label: 'Uploaded'),
                            const SizedBox(width: 24),
                            _ProgressStat(value: '$valid', label: 'Verified'),
                            const SizedBox(width: 24),
                            _ProgressStat(
                              value: '${total - uploaded}',
                              label: 'Pending',
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
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Accepted formats: PDF, JPG, PNG. Max size 5MB per file.',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...requiredDocumentTypes.map((docType) {
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
      statusText = 'Not Uploaded';
      statusSubtext = 'Tap upload to add this document';
    } else if (isPending) {
      borderColor = Colors.orange.withValues(alpha: 0.5);
      iconBg = Colors.orange.withValues(alpha: 0.1);
      iconColor = Colors.orange;
      statusIcon = Icons.hourglass_top_rounded;
      statusText = 'Pending Review';
      statusSubtext = 'Uploaded — awaiting admin verification';
    } else if (isValid == true) {
      borderColor = Colors.green.withValues(alpha: 0.5);
      iconBg = Colors.green.withValues(alpha: 0.1);
      iconColor = Colors.green;
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Verified';
      statusSubtext = 'This document has been accepted';
    } else {
      borderColor = Colors.red.withValues(alpha: 0.5);
      iconBg = Colors.red.withValues(alpha: 0.1);
      iconColor = Colors.red;
      statusIcon = Icons.cancel_rounded;
      statusText = 'Invalid';
      statusSubtext = document?.remark ?? 'Please re-upload a valid document';
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
                        const SnackBar(
                          content: Text('Opening document preview…'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View', style: TextStyle(fontSize: 13)),
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
                          ? 'Re-upload'
                          : isUploaded
                              ? 'Replace'
                              : 'Upload',
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
