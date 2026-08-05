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
  DistributionMethod _method = DistributionMethod.online;
  bool _bulkMode = false;
  bool _isSubmitting = false;
  int _formResetCount = 0;

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
      method: _method,
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
      setState(() {
        _selectedApplicationId = null;
        _formResetCount++;
      });
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

  Future<void> _submitBulk(CardType cardType, int recipientCount) async {
    final amount = double.tryParse(_bulkAmountController.text.trim());
    if (amount == null) return;
    final total = amount * recipientCount;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.trs('bulk_distribute_confirm_title')),
        content: Text(
          context.trsp('bulk_distribute_confirm_body', {
            'amount': amount.toStringAsFixed(0),
            'count': '$recipientCount',
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
      cardTypeId: cardType.id,
      amount: amount,
      method: _method,
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

  Widget _buildIndividualForm(
    BuildContext context,
    AdminProvider provider,
    List<Application> approved,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(_formResetCount),
            initialValue: _selectedApplicationId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.tr('approved_card_holder_label'),
              prefixIcon: const Icon(Icons.person),
            ),
            items: approved.map((a) {
              final eligible = provider.isEligibleForDistribution(a.id);
              final baseLabel =
                  '${a.applicantName ?? a.id} — ${a.cardTypeName}';
              final eligibleOn = eligible
                  ? null
                  : provider.eligibleAgainOn(a.id);
              final label = eligible || eligibleOn == null
                  ? baseLabel
                  : '$baseLabel (${context.trsp('on_cooldown_until_label', {'date': DateFormat('dd MMM').format(eligibleOn)})})';
              return DropdownMenuItem(
                value: a.id,
                enabled: eligible,
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: eligible
                      ? null
                      : const TextStyle(color: AppTheme.textTertiary),
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedApplicationId = v),
          ),
          const SizedBox(height: 16),
          _methodSelector(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.tr('amount_bdt_label'),
              prefixIcon: const Icon(Icons.money),
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
              _bulkAmountController.text =
                  selected == null || selected.disbursementAmount == 0
                  ? ''
                  : selected.disbursementAmount.toStringAsFixed(0);
            });
          },
        ),
        const SizedBox(height: 16),
        _methodSelector(),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bulkAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: context.tr('amount_bdt_label'),
            prefixIcon: const Icon(Icons.money),
          ),
          onChanged: (_) => setState(() {}),
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
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              (_isSubmitting ||
                  cardType == null ||
                  recipients.isEmpty ||
                  double.tryParse(_bulkAmountController.text.trim()) == null)
              ? null
              : () => _submitBulk(cardType, recipients.length),
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
                    'count': '${recipients.length}',
                  }),
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ],
    );
  }

  Widget _methodSelector() {
    return SegmentedButton<DistributionMethod>(
      segments: [
        ButtonSegment(
          value: DistributionMethod.online,
          label: Text(context.tr('online_method_full')),
          icon: const Icon(Icons.account_balance_wallet),
        ),
        ButtonSegment(
          value: DistributionMethod.offline,
          label: Text(context.tr('offline')),
          icon: const Icon(Icons.storefront),
        ),
      ],
      selected: {_method},
      onSelectionChanged: (s) => setState(() => _method = s.first),
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
