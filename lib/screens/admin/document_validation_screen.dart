import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/providers/application_provider.dart';
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
  String? _selectedCardTypeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocuments();
      context.read<ApplicationProvider>().loadCardTypes();
    });
  }

  Future<void> _loadDocuments() {
    return context.read<AdminProvider>().loadDocuments(
      citizenId: widget.filter?.citizenId,
      citizenEmail: widget.filter?.citizenEmail,
    );
  }

  ({IconData icon, Color color}) _styleFor(CardTypeCode code) {
    switch (code) {
      case CardTypeCode.farmer:
        return (
          icon: Icons.agriculture_rounded,
          color: const Color(0xFF059669),
        );
      case CardTypeCode.family:
        return (
          icon: Icons.family_restroom_rounded,
          color: const Color(0xFF2563EB),
        );
      case CardTypeCode.education:
        return (icon: Icons.school_rounded, color: const Color(0xFF7C3AED));
    }
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
    final cardTypes = context.watch<ApplicationProvider>().cardTypes;
    final applicationId = widget.filter?.applicationId;
    final showCardTypeSummary =
        applicationId == null && _selectedCardTypeId == null;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: widget.standalone
          ? AppBar(title: Text(context.tr('admin_nav_document_validation')))
          : null,
      body: showCardTypeSummary
          ? _buildCardTypeSummary(provider, cardTypes)
          : _buildDocumentList(provider, applicationId),
    );
  }

  Widget _buildCardTypeSummary(
    AdminProvider provider,
    List<CardType> cardTypes,
  ) {
    if (cardTypes.isEmpty || provider.isLoadingDocuments) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cardTypes.length,
        itemBuilder: (context, index) {
          final cardType = cardTypes[index];
          final docsForCard = provider.documents
              .where((d) => d.cardTypeId == cardType.id)
              .toList();
          final pendingCount = docsForCard
              .where((d) => d.isValid == null)
              .length;
          final style = _styleFor(cardType.code);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _selectedCardTypeId = cardType.id),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: style.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(style.icon, color: style.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        cardType.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      context.trp('card_documents_summary', {
                        'total': '${docsForCard.length}',
                        'pending': '$pendingCount',
                      }),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: pendingCount > 0
                            ? AppTheme.warningAmber
                            : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentList(AdminProvider provider, String? applicationId) {
    final scopedDocs = _showReviewed
        ? provider.reviewedDocuments
        : provider.pendingDocuments;
    final docs = applicationId != null
        ? scopedDocs.where((d) => d.applicationId == applicationId).toList()
        : scopedDocs.where((d) => d.cardTypeId == _selectedCardTypeId).toList();
    final showBackHeader = applicationId == null && _selectedCardTypeId != null;

    return Column(
      children: [
        if (showBackHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => setState(() => _selectedCardTypeId = null),
                ),
                Expanded(
                  child: Text(
                    context
                            .watch<ApplicationProvider>()
                            .cardTypes
                            .where((c) => c.id == _selectedCardTypeId)
                            .firstOrNull
                            ?.name ??
                        '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            onSelectionChanged: (s) => setState(() => _showReviewed = s.first),
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
                                style: TextStyle(color: AppTheme.textSecondary),
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
                                            (context, error, stackTrace) =>
                                                Container(
                                                  height: 140,
                                                  width: double.infinity,
                                                  color: AppTheme.surfaceLight,
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color:
                                                        AppTheme.textSecondary,
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
                                      label: Text(context.tr('invalid_action')),
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
