import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class FundDistributionScreen extends StatefulWidget {
  const FundDistributionScreen({super.key});

  @override
  State<FundDistributionScreen> createState() => _FundDistributionScreenState();
}

class _FundDistributionScreenState extends State<FundDistributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedApplicationId;
  DistributionMethod _method = DistributionMethod.online;
  bool _isSubmitting = false;
  int _formResetCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadApplications(status: ApplicationStatus.approved);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedApplicationId == null) {
      if (_selectedApplicationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an approved card holder'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<AdminProvider>();
    final success = await provider.createDistribution(
      applicationId: _selectedApplicationId!,
      method: _method,
      amount: double.parse(_amountController.text.trim()),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funds disbursed successfully'), backgroundColor: Colors.green),
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
        SnackBar(content: Text(provider.distributionsError ?? 'Failed to disburse funds'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final approved = provider.applications.where((a) => a.status == ApplicationStatus.approved).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey(_formResetCount),
                initialValue: _selectedApplicationId,
                decoration: const InputDecoration(labelText: 'Approved Card Holder', prefixIcon: Icon(Icons.person)),
                items: approved
                    .map((a) => DropdownMenuItem(value: a.id, child: Text('${a.applicantName ?? a.id} — ${a.cardTypeName}')))
                    .toList(),
                onChanged: (v) => setState(() => _selectedApplicationId = v),
              ),
              const SizedBox(height: 16),
              SegmentedButton<DistributionMethod>(
                segments: const [
                  ButtonSegment(value: DistributionMethod.online, label: Text('Online (bKash/Nagad/Bank)'), icon: Icon(Icons.account_balance_wallet)),
                  ButtonSegment(value: DistributionMethod.offline, label: Text('Offline'), icon: Icon(Icons.storefront)),
                ],
                selected: {_method},
                onSelectionChanged: (s) => setState(() => _method = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (BDT)', prefixIcon: Icon(Icons.money)),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter a valid amount' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.note)),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Disburse Funds', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
