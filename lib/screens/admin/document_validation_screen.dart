import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class DocumentValidationScreen extends StatefulWidget {
  const DocumentValidationScreen({
    super.key,
    this.filter,
    this.standalone = false,
  });

  final DocumentValidationFilterArgs? filter;
  final bool standalone;

  @override
  State<DocumentValidationScreen> createState() =>
      _DocumentValidationScreenState();
}

class _DocumentValidationScreenState extends State<DocumentValidationScreen> {
  bool _showReviewed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocuments();
    });
  }

  Future<void> _loadDocuments() {
    return context.read<AdminProvider>().loadDocuments(
      citizenId: widget.filter?.citizenId,
      citizenEmail: widget.filter?.citizenEmail,
    );
  }

  Future<void> _viewDocument(CitizenDocument doc) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminProvider>(),
          child: _DocumentViewerScreen(
            document: doc,
            onMarkValid: () => _markValid(doc),
            onMarkInvalid: () => _markInvalid(doc),
          ),
        ),
      ),
    );
  }

  Future<void> _markInvalid(CitizenDocument doc) async {
    final remarkController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.trs('mark_document_invalid_title')),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: remarkController,
            decoration: InputDecoration(labelText: context.trs('remark_label')),
            maxLines: 2,
            validator: (v) => (v == null || v.isEmpty)
                ? context.trs('remark_required')
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
            child: Text(context.trs('mark_invalid_action')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AdminProvider>().validateDocument(
        doc.id,
        isValid: false,
        remark: remarkController.text.trim(),
      );
    }
  }

  Future<void> _markValid(CitizenDocument doc) async {
    await context.read<AdminProvider>().validateDocument(doc.id, isValid: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final scopedDocs = _showReviewed
        ? provider.reviewedDocuments
        : provider.pendingDocuments;
    final applicationId = widget.filter?.applicationId;
    final docs = applicationId == null
        ? scopedDocs
        : scopedDocs.where((d) => d.applicationId == applicationId).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: widget.standalone
          ? AppBar(title: Text(context.tr('admin_nav_document_validation')))
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(context.tr('doc_validation_tab_pending')),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(context.tr('doc_validation_tab_reviewed')),
                ),
              ],
              selected: {_showReviewed},
              onSelectionChanged: (s) =>
                  setState(() => _showReviewed = s.first),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDocuments,
              child: provider.isLoadingDocuments
                  ? const Center(child: CircularProgressIndicator())
                  : provider.documentsError != null
                  ? ErrorMessage(
                      message: provider.documentsError!,
                      onRetry: _loadDocuments,
                    )
                  : docs.isEmpty
                  ? EmptyListMessage(
                      message: context.tr(
                        _showReviewed
                            ? 'no_reviewed_documents'
                            : 'no_documents_to_review',
                      ),
                      icon: Icons.fact_check_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      doc.isValid == true
                                          ? Icons.check_circle
                                          : doc.isValid == false
                                          ? Icons.cancel
                                          : Icons.hourglass_empty,
                                      color: doc.isValid == true
                                          ? Colors.green
                                          : doc.isValid == false
                                          ? Colors.red
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        documentTypeLabel(doc.docType),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.trp('citizen_prefix', {
                                    'name': doc.citizenName ?? doc.citizenId,
                                  }),
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                if (doc.remark != null)
                                  Text(
                                    context.trp('remark_prefix', {
                                      'remark': doc.remark!,
                                    }),
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => _viewDocument(doc),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.network(
                                          doc.fileUrl,
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                progress,
                                              ) => progress == null
                                              ? child
                                              : Container(
                                                  height: 140,
                                                  color: AppTheme.surfaceLight,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                          errorBuilder:
                                              (
                                                context,
                                                error,
                                                stackTrace,
                                              ) => Container(
                                                height: 140,
                                                width: double.infinity,
                                                color: AppTheme.surfaceLight,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.55,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.zoom_in,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                context.tr('view_document'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _markInvalid(doc),
                                        icon: const Icon(Icons.close, size: 18),
                                        label: Text(
                                          context.tr('invalid_action'),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _markValid(doc),
                                        icon: const Icon(Icons.check, size: 18),
                                        label: Text(context.tr('valid_action')),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

class DocumentValidationFilterArgs {
  const DocumentValidationFilterArgs({
    this.citizenId,
    this.citizenEmail,
    this.citizenName,
    this.applicationId,
  });

  final String? citizenId;
  final String? citizenEmail;
  final String? citizenName;

  /// When set, only documents attached to this specific application are
  /// shown — a citizen may have applied for multiple cards, each needing
  /// its own set of documents reviewed independently.
  final String? applicationId;
}

class _DocumentViewerScreen extends StatefulWidget {
  const _DocumentViewerScreen({
    required this.document,
    required this.onMarkValid,
    required this.onMarkInvalid,
  });

  final CitizenDocument document;
  final Future<void> Function() onMarkValid;
  final Future<void> Function() onMarkInvalid;

  @override
  State<_DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<_DocumentViewerScreen> {
  bool _submitting = false;

  Future<void> _handle(Future<void> Function() action) async {
    setState(() => _submitting = true);
    await action();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(documentTypeLabel(doc.docType)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.trp('citizen_prefix', {
                      'name': doc.citizenName ?? doc.citizenId,
                    }),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: Center(
                child: Image.network(
                  doc.fileUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const CircularProgressIndicator(),
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _submitting
                          ? null
                          : () => _handle(widget.onMarkInvalid),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(context.tr('invalid_action')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitting
                          ? null
                          : () => _handle(widget.onMarkValid),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(context.tr('valid_action')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
