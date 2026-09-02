import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:provider/provider.dart';

class FundDistributionScreen extends StatefulWidget {
  const FundDistributionScreen({super.key});

  @override
  State<FundDistributionScreen> createState() => _FundDistributionScreenState();
}

class _FundDistributionScreenState extends State<FundDistributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _bulkAmountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedApplicationId;
  String? _selectedCardTypeId;
  bool _bulkMode = false;
  bool _isSubmitting = false;
  final Set<String> _deselectedRecipientIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadApplications(
        status: ApplicationStatus.approved,
      );
      context.read<AdminProvider>().loadDistributions();
      context.read<ApplicationProvider>().loadCardTypes();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bulkAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedApplicationId == null) {
      if (_selectedApplicationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.trs('select_card_holder_error')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final provider = context.read<AdminProvider>();
    if (!provider.isEligibleForDistribution(_selectedApplicationId!)) {
      final eligibleOn = provider.eligibleAgainOn(_selectedApplicationId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.trsp('recipient_on_cooldown_error', {
              'date': eligibleOn == null
                  ? ''
                  : DateFormat('dd MMM yyyy').format(eligibleOn),
            }),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await provider.createDistribution(
      applicationId: _selectedApplicationId!,
      method: DistributionMethod.online,
      amount: double.parse(_amountController.text.trim()),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trs('funds_disbursed_success')),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState!.reset();
      _amountController.clear();
      _noteController.clear();
      setState(() => _selectedApplicationId = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.distributionsError ?? context.trs('disburse_failed'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitBulk(
    CardType cardType,
    List<Application> recipients,
  ) async {
    final amount = double.tryParse(_bulkAmountController.text.trim());
    if (amount == null || recipients.isEmpty) return;
    final total = amount * recipients.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.trs('bulk_distribute_confirm_title')),
        content: Text(
          context.trsp('bulk_distribute_confirm_body', {
            'amount': amount.toStringAsFixed(0),
            'count': '${recipients.length}',
            'name': cardType.name,
            'total': total.toStringAsFixed(0),
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.trs('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.trs('confirm_send_action')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<AdminProvider>();
    final result = await provider.distributeToCardType(
      applicationIds: recipients.map((a) => a.id).toList(),
      amount: amount,
      method: DistributionMethod.online,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.trsp('bulk_distribute_result', {
            'success': '${result.success}',
            'failed': '${result.failed}',
          }),
        ),
        backgroundColor: result.failed == 0 ? Colors.green : Colors.orange,
      ),
    );
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final approved = provider.applications
        .where((a) => a.status == ApplicationStatus.approved)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(context.tr('distribution_mode_individual')),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(context.tr('distribution_mode_bulk')),
                ),
              ],
              selected: {_bulkMode},
              onSelectionChanged: (s) => setState(() => _bulkMode = s.first),
            ),
            const SizedBox(height: 16),
            _bulkMode
                ? _buildBulkForm(context)
                : _buildIndividualForm(context, provider, approved),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCardHolder(
    AdminProvider provider,
    List<Application> approved,
    List<CardType> cardTypes,
  ) async {
    final selected = await showModalBottomSheet<Application>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _CardHolderSearchSheet(applications: approved, provider: provider),
    );
    if (selected == null || !mounted) return;
    final cardType = cardTypes
        .where((c) => c.id == selected.cardTypeId)
        .firstOrNull;
    setState(() {
      _selectedApplicationId = selected.id;
      _amountController.text =
          cardType == null || cardType.disbursementAmount == 0
          ? ''
          : cardType.disbursementAmount.toStringAsFixed(0);
    });
  }

  Widget _buildIndividualForm(
    BuildContext context,
    AdminProvider provider,
    List<Application> approved,
  ) {
    final cardTypes = context.watch<ApplicationProvider>().cardTypes;
    final selectedApplication = approved
        .where((a) => a.id == _selectedApplicationId)
        .firstOrNull;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _pickCardHolder(provider, approved, cardTypes),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: context.tr('approved_card_holder_label'),
                prefixIcon: const Icon(Icons.person),
                suffixIcon: const Icon(Icons.search_rounded),
              ),
              child: Text(
                selectedApplication == null
                    ? context.trs('select_card_holder_hint')
                    : '${selectedApplication.applicantName ?? selectedApplication.id} — ${selectedApplication.cardTypeName}',
                overflow: TextOverflow.ellipsis,
                style: selectedApplication == null
                    ? const TextStyle(color: AppTheme.textTertiary)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _onlineMethodBadge(context),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: context.tr('amount_bdt_label'),
              prefixIcon: const Icon(Icons.money),
              suffixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
              filled: true,
              fillColor: AppTheme.surfaceLight,
            ),
            validator: (v) => (v == null || double.tryParse(v) == null)
                ? context.trs('amount_invalid')
                : null,
          ),
          const SizedBox(height: 16),
          _noteField(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    context.tr('disburse_funds_action'),
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkForm(BuildContext context) {
    final cardTypes = context.watch<ApplicationProvider>().cardTypes;
    final provider = context.watch<AdminProvider>();
    final cardType = cardTypes
        .where((c) => c.id == _selectedCardTypeId)
        .firstOrNull;
    final approvedForCard = cardType == null
        ? const <Application>[]
        : provider.applications
              .where(
                (a) =>
                    a.cardTypeId == cardType.id &&
                    a.status == ApplicationStatus.approved,
              )
              .toList();
    final recipients = approvedForCard
        .where((a) => provider.isEligibleForDistribution(a.id))
        .toList();
    final onCooldownCount = approvedForCard.length - recipients.length;
    final selectedRecipients = recipients
        .where((a) => !_deselectedRecipientIds.contains(a.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedCardTypeId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: context.tr('card_type_label'),
            prefixIcon: const Icon(Icons.badge),
          ),
          items: cardTypes
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) {
            final selected = cardTypes.where((c) => c.id == v).firstOrNull;
            setState(() {
              _selectedCardTypeId = v;
              _deselectedRecipientIds.clear();
              _bulkAmountController.text =
                  selected == null || selected.disbursementAmount == 0
                  ? ''
                  : selected.disbursementAmount.toStringAsFixed(0);
            });
          },
        ),
        const SizedBox(height: 16),
        _onlineMethodBadge(context),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bulkAmountController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: context.tr('amount_bdt_label'),
            prefixIcon: const Icon(Icons.money),
            suffixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
            filled: true,
            fillColor: AppTheme.surfaceLight,
          ),
        ),
        const SizedBox(height: 16),
        _noteField(),
        const SizedBox(height: 16),
        if (cardType != null)
          Card(
            color: recipients.isEmpty
                ? AppTheme.surfaceLight
                : AppTheme.primaryGreen.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipients.isEmpty
                        ? context.trs('no_approved_holders_for_card')
                        : context.trsp('bulk_recipients_summary', {
                            'count': '${recipients.length}',
                            'name': cardType.name,
                            'amount':
                                (double.tryParse(
                                          _bulkAmountController.text.trim(),
                                        ) ??
                                        0)
                                    .toStringAsFixed(0),
                          }),
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  if (onCooldownCount > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      context.trp('recipients_on_cooldown_note', {
                        'count': '$onCooldownCount',
                        'days': '${AdminProvider.distributionCooldownDays}',
                      }),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.warningAmber,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        if (recipients.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.trp('recipients_selected_count', {
                  'selected': '${selectedRecipients.length}',
                  'total': '${recipients.length}',
                }),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  if (_deselectedRecipientIds.isEmpty) {
                    _deselectedRecipientIds.addAll(recipients.map((a) => a.id));
                  } else {
                    _deselectedRecipientIds.clear();
                  }
                }),
                child: Text(
                  context.tr(
                    _deselectedRecipientIds.isEmpty
                        ? 'deselect_all_action'
                        : 'select_all_action',
                  ),
                ),
              ),
            ],
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: recipients.map((application) {
                final selected = !_deselectedRecipientIds.contains(
                  application.id,
                );
                return CheckboxListTile(
                  value: selected,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    application.applicantName ?? application.id,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onChanged: (value) => setState(() {
                    if (value == true) {
                      _deselectedRecipientIds.remove(application.id);
                    } else {
                      _deselectedRecipientIds.add(application.id);
                    }
                  }),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              (_isSubmitting ||
                  cardType == null ||
                  selectedRecipients.isEmpty ||
                  double.tryParse(_bulkAmountController.text.trim()) == null)
              ? null
              : () => _submitBulk(cardType, selectedRecipients),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  context.trp('bulk_distribute_action', {
                    'count': '${selectedRecipients.length}',
                  }),
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ],
    );
  }

  Widget _onlineMethodBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            context.tr('online_method_full'),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteField() {
    return TextFormField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: context.tr('note_optional_label'),
        prefixIcon: const Icon(Icons.note),
      ),
      maxLines: 2,
    );
  }
}

/// Search sheet for picking the individual-distribution recipient — lets
/// the admin filter by name, card type, or NID instead of scrolling a long
/// dropdown once there are many approved holders.
class _CardHolderSearchSheet extends StatefulWidget {
  const _CardHolderSearchSheet({
    required this.applications,
    required this.provider,
  });

  final List<Application> applications;
  final AdminProvider provider;

  @override
  State<_CardHolderSearchSheet> createState() => _CardHolderSearchSheetState();
}

class _CardHolderSearchSheetState extends State<_CardHolderSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final results = query.isEmpty
        ? widget.applications
        : widget.applications
              .where(
                (a) =>
                    (a.applicantName ?? '').toLowerCase().contains(query) ||
                    a.cardTypeName.toLowerCase().contains(query) ||
                    (a.applicantNid ?? '').toLowerCase().contains(query),
              )
              .toList();

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('approved_card_holder_label'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: context.tr('search_card_holder_hint'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => setState(() {
                              _controller.clear();
                              _query = '';
                            }),
                          ),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text(
                          context.tr('no_matching_applications'),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final app = results[index];
                          final eligible = widget.provider
                              .isEligibleForDistribution(app.id);
                          final eligibleOn = eligible
                              ? null
                              : widget.provider.eligibleAgainOn(app.id);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              enabled: eligible,
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryGreen
                                    .withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.person,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              title: Text(
                                '${app.applicantName ?? app.id} — ${app.cardTypeName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: eligible || eligibleOn == null
                                  ? null
                                  : Text(
                                      context.trp('on_cooldown_until_label', {
                                        'date': DateFormat(
                                          'dd MMM',
                                        ).format(eligibleOn),
                                      }),
                                      style: const TextStyle(
                                        color: AppTheme.warningAmber,
                                      ),
                                    ),
                              onTap: eligible
                                  ? () => Navigator.of(context).pop(app)
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
