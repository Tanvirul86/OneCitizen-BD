import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/occupation.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class EligibilityScreen extends StatefulWidget {
  const EligibilityScreen({super.key});

  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  final _formKey = GlobalKey<FormState>();

  _EligibilityCardOption? _selectedCard;

  final _incomeController = TextEditingController();
  final _landController = TextEditingController();
  final _sscController = TextEditingController();
  final _hscController = TextEditingController();

  Occupation? _occupation;
  bool _hasFarmerCert = false;
  bool _hasWardCert = false;
  bool _hasWorkerCertificate = false;
  bool _hasLaborRegistration = false;

  bool get _isFarmer => _selectedCard == _EligibilityCardOption.farmer;
  bool get _isFamily => _selectedCard == _EligibilityCardOption.family;
  bool get _isEducation => _selectedCard == _EligibilityCardOption.education;
  bool get _isWorker => _selectedCard == _EligibilityCardOption.worker;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _incomeController.text = user.income?.toStringAsFixed(0) ?? '';
      _landController.text = user.landAcres?.toString() ?? '';
      _sscController.text = user.sscGpa?.toString() ?? '';
      _hscController.text = user.hscGpa?.toString() ?? '';
      _occupation = occupationFromString(user.occupation);
    }
  }

  void _onOccupationChanged(Occupation? value) {
    setState(() {
      _occupation = value;
      if (value != Occupation.farmer) {
        _landController.clear();
        _hasFarmerCert = false;
        _hasWardCert = false;
      }
      if (value != Occupation.student) {
        _sscController.clear();
        _hscController.clear();
      }
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _landController.dispose();
    _sscController.dispose();
    _hscController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'occupation': _occupation != null ? occupationToString(_occupation!) : '',
      'income': double.tryParse(_incomeController.text) ?? 0,
      'land_acres': double.tryParse(_landController.text) ?? 0,
      'ssc_gpa': double.tryParse(_sscController.text),
      'hsc_gpa': double.tryParse(_hscController.text),
      'has_farmer_cert': _hasFarmerCert,
      'has_ward_cert': _hasWardCert,
    };

    final appProvider = context.read<ApplicationProvider>();
    final success = await appProvider.submitEligibilityRequest(data);
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appProvider.eligibilitySubmitError ??
                'Submission failed. Please try again.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();
    final submitted = appProvider.eligibilityRequestStatus != null;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('Check Eligibility')),
      body: submitted
          ? _buildPendingView(appProvider)
          : _buildForm(appProvider),
    );
  }

  Widget _buildPendingView(ApplicationProvider appProvider) {
    final status = appProvider.eligibilityRequestStatus ?? 'pending_review';
    final isPending = status == 'pending_review';
    final isApproved = status == 'approved';

    final color = isApproved
        ? Colors.green
        : isPending
        ? Colors.orange
        : Colors.red;
    final icon = isApproved
        ? Icons.check_circle_rounded
        : isPending
        ? Icons.hourglass_top_rounded
        : Icons.cancel_rounded;
    final title = isApproved
        ? 'Eligibility Approved'
        : isPending
        ? 'Request Submitted'
        : 'Request Rejected';
    final message = isApproved
        ? 'Your eligibility has been confirmed by the admin. You can now apply for the cards you are eligible for.'
        : isPending
        ? 'Your eligibility request has been submitted successfully. An admin will review your details and notify you of the decision.'
        : 'Your eligibility request was not approved. Please contact your local authority for assistance.';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 52),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You will receive a notification once the admin reviews your request.',
                      style: TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isApproved) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/citizen/apply'),
              icon: const Icon(Icons.add_card),
              label: const Text('Apply for a Card'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextButton(
            onPressed: () =>
                context.read<ApplicationProvider>().resetEligibilityRequest(),
            child: const Text('Edit & Resubmit'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ApplicationProvider appProvider) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Choose one card type, then fill only the fields required for that card.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryGreen,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Select Card Type', icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          DropdownButtonFormField<Occupation>(
            initialValue: _occupation,
            decoration: const InputDecoration(
              labelText: 'Occupation',
              prefixIcon: Icon(Icons.work_outline),
            ),
            items: Occupation.values
                .map((o) => DropdownMenuItem(value: o, child: Text(occupationLabel(o))))
                .toList(),
            onChanged: _onOccupationChanged,
            validator: (v) => v == null ? 'Occupation is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _incomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monthly Household Income (BDT)',
              hintText: 'e.g. 10000',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              suffixText: 'BDT',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Income is required';
              if (double.tryParse(v) == null) return 'Enter a valid amount';
              return null;
            },
          ),
          const SizedBox(height: 24),

          if (_occupation == Occupation.farmer) ...[
            // Section: Farmer Card
            _SectionHeader(
              title: 'Farmer Card',
              icon: Icons.agriculture_rounded,
              subtitle: 'Must be ≤ 0.50 acres land, monthly income ≤ BDT 12,000',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _landController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Land Owned (Acres)',
                hintText: 'e.g. 0.50 (enter 0 if none)',
                prefixIcon: Icon(Icons.terrain_outlined),
                suffixText: 'acres',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Land information is required';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _CheckCard(
              title: 'I have an Agricultural Farmer Certificate',
              subtitle: 'Issued by local union/ward parishad',
              value: _hasFarmerCert,
              onChanged: (v) => setState(() => _hasFarmerCert = v ?? false),
            ),
            const SizedBox(height: 8),
            _CheckCard(
              title: 'I have a Ward/Union Certificate',
              subtitle: 'Confirming land holding and residence',
              value: _hasWardCert,
              onChanged: (v) => setState(() => _hasWardCert = v ?? false),
            ),
            const SizedBox(height: 24),
          ],

          if (_occupation == Occupation.student) ...[
            // Section: Education Card
            _SectionHeader(
              title: 'Education Card',
              icon: Icons.school_rounded,
              subtitle: 'Requires GPA 5.00 in both SSC and HSC',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sscController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'SSC GPA (leave blank if not applicable)',
                hintText: 'e.g. 5.00',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final gpa = double.tryParse(v);
                  if (gpa == null || gpa < 0 || gpa > 5) return 'Enter GPA between 0.00 and 5.00';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hscController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'HSC GPA (leave blank if not applicable)',
                hintText: 'e.g. 5.00',
                prefixIcon: Icon(Icons.school_rounded),
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final gpa = double.tryParse(v);
                  if (gpa == null || gpa < 0 || gpa > 5) return 'Enter GPA between 0.00 and 5.00';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 24),

          // Submit button
          ElevatedButton.icon(
            onPressed: appProvider.isSubmittingEligibility ? null : _submit,
            icon: appProvider.isSubmittingEligibility
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              appProvider.isSubmittingEligibility ? 'Submitting...' : 'Submit Eligibility Request',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your information will be reviewed by the admin within 2–3 working days.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    this.subtitle,
  });
  final String title;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value
              ? AppTheme.primaryGreen.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppTheme.primaryGreen : AppTheme.divider,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
