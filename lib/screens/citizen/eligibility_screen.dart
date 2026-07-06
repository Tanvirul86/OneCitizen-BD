import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
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
  final _occupationController = TextEditingController();
  final _otherWorkerOccupationController = TextEditingController();

  String? _selectedWorkerOccupation;

  bool _hasFarmerCert = false;
  bool _hasWardCert = false;
  bool _hasWorkerCertificate = false;
  bool _hasLaborRegistration = false;

  bool get _isFarmer => _selectedCard == _EligibilityCardOption.farmer;
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
      _occupationController.text = user.occupation ?? '';
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _landController.dispose();
    _sscController.dispose();
    _hscController.dispose();
    _occupationController.dispose();
    _otherWorkerOccupationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'selected_card_type': _selectedCard!.code,
      'occupation': _isFarmer
          ? _occupationController.text.trim()
          : _isWorker
          ? _workerOccupationValue
          : null,
      'income': _isFarmer || _isWorker
          ? double.tryParse(_incomeController.text) ?? 0
          : null,
      'land_acres': _isFarmer
          ? double.tryParse(_landController.text) ?? 0
          : null,
      'ssc_gpa': _isEducation ? double.tryParse(_sscController.text) : null,
      'hsc_gpa': _isEducation ? double.tryParse(_hscController.text) : null,
      'has_farmer_cert': _isFarmer && _hasFarmerCert,
      'has_ward_cert': _isFarmer && _hasWardCert,
      'has_worker_certificate': _isWorker && _hasWorkerCertificate,
      'has_labor_registration': _isWorker && _hasLaborRegistration,
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
          DropdownButtonFormField<_EligibilityCardOption>(
            initialValue: _selectedCard,
            decoration: const InputDecoration(
              labelText: 'Card Type',
              hintText: 'Choose Farmer, Education, or Worker card',
              prefixIcon: Icon(Icons.credit_card_rounded),
            ),
            items: _EligibilityCardOption.values
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option.title),
                  ),
                )
                .toList(),
            onChanged: (option) => setState(() {
              _selectedCard = option;
              if (option != _EligibilityCardOption.worker) {
                _selectedWorkerOccupation = null;
                _otherWorkerOccupationController.clear();
              }
            }),
            validator: (value) =>
                value == null ? 'Please select a card type' : null,
          ),
          if (_selectedCard != null) ...[
            const SizedBox(height: 24),
            _buildSelectedCardFields(),
          ],
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: appProvider.isSubmittingEligibility ? null : _submit,
            icon: appProvider.isSubmittingEligibility
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              appProvider.isSubmittingEligibility
                  ? 'Submitting...'
                  : 'Submit Eligibility Request',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your information will be reviewed by the admin within 2-3 working days.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSelectedCardFields() {
    switch (_selectedCard!) {
      case _EligibilityCardOption.farmer:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Farmer Card',
              icon: Icons.agriculture_rounded,
              subtitle:
                  'Must be <= 0.50 acres land, monthly income <= BDT 12,000',
            ),
            const SizedBox(height: 12),
            _OccupationField(controller: _occupationController),
            const SizedBox(height: 16),
            _IncomeField(controller: _incomeController),
            const SizedBox(height: 16),
            TextFormField(
              controller: _landController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Land Owned (Acres)',
                hintText: 'e.g. 0.50 (enter 0 if none)',
                prefixIcon: Icon(Icons.terrain_outlined),
                suffixText: 'acres',
              ),
              validator: _requiredNumberValidator(
                'Land information is required',
              ),
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
          ],
        );
      case _EligibilityCardOption.education:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Education Card',
              icon: Icons.school_rounded,
              subtitle: 'Requires GPA 5.00 in both SSC and HSC',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sscController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'SSC GPA',
                hintText: 'e.g. 5.00',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              validator: _gpaValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hscController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'HSC GPA',
                hintText: 'e.g. 5.00',
                prefixIcon: Icon(Icons.school_rounded),
              ),
              validator: _gpaValidator,
            ),
          ],
        );
      case _EligibilityCardOption.worker:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Worker Card',
              icon: Icons.engineering_rounded,
              subtitle: 'For low-income registered workers',
            ),
            const SizedBox(height: 12),
            _WorkerOccupationField(
              value: _selectedWorkerOccupation,
              otherController: _otherWorkerOccupationController,
              onChanged: (value) {
                setState(() {
                  _selectedWorkerOccupation = value;
                  if (value != _otherWorkerOccupationCode) {
                    _otherWorkerOccupationController.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            _IncomeField(controller: _incomeController),
            const SizedBox(height: 16),
            _CheckCard(
              title: 'I have a Worker/Employment Certificate',
              subtitle: 'Issued by employer, union, or local authority',
              value: _hasWorkerCertificate,
              onChanged: (v) =>
                  setState(() => _hasWorkerCertificate = v ?? false),
            ),
            const SizedBox(height: 8),
            _CheckCard(
              title: 'I am registered with a labor/worker organization',
              subtitle: 'Registration, union, or worker ID available',
              value: _hasLaborRegistration,
              onChanged: (v) =>
                  setState(() => _hasLaborRegistration = v ?? false),
            ),
          ],
        );
    }
  }

  FormFieldValidator<String> _requiredNumberValidator(String requiredMessage) {
    return (v) {
      if (v == null || v.trim().isEmpty) return requiredMessage;
      if (double.tryParse(v) == null) return 'Enter a valid number';
      return null;
    };
  }

  String? _gpaValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'GPA is required';
    final gpa = double.tryParse(v);
    if (gpa == null || gpa < 0 || gpa > 5) {
      return 'Enter GPA between 0.00 and 5.00';
    }
    return null;
  }

  String get _workerOccupationValue {
    if (_selectedWorkerOccupation == _otherWorkerOccupationCode) {
      return _otherWorkerOccupationController.text.trim();
    }
    return _selectedWorkerOccupation ?? '';
  }
}

const _otherWorkerOccupationCode = 'other';

const _workerOccupationOptions = [
  'Garments worker',
  'Construction worker',
  'Rickshaw puller',
  'Van puller',
  'Day laborer',
  'Domestic worker',
  'Cleaner',
  'Security guard',
  'Street vendor',
  'Transport helper',
  'Factory worker',
  'Agricultural laborer',
  'Tea garden worker',
  'Fisherman',
  'Small shop assistant',
  'Delivery worker',
  'Hotel/restaurant worker',
  'Other occupation',
];

enum _EligibilityCardOption {
  farmer('farmer', 'Farmer Card'),
  education('education', 'Education Card'),
  worker('worker', 'Worker Card');

  const _EligibilityCardOption(this.code, this.title);

  final String code;
  final String title;
}

class _OccupationField extends StatelessWidget {
  const _OccupationField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Occupation',
        hintText: 'e.g. Farmer, employee, daily worker',
        prefixIcon: const Icon(Icons.work_outline),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Occupation is required' : null,
    );
  }
}

class _WorkerOccupationField extends StatelessWidget {
  const _WorkerOccupationField({
    required this.value,
    required this.otherController,
    required this.onChanged,
  });

  final String? value;
  final TextEditingController otherController;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isOtherSelected = value == _otherWorkerOccupationCode;

    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: const InputDecoration(
            labelText: 'Occupation',
            hintText: 'Please select your occupation',
            prefixIcon: Icon(Icons.work_outline),
          ),
          items: _workerOccupationOptions.map((occupation) {
            final itemValue = occupation == 'Other occupation'
                ? _otherWorkerOccupationCode
                : occupation;
            return DropdownMenuItem<String>(
              value: itemValue,
              child: Text(occupation),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (selected) =>
              selected == null ? 'Please select your occupation' : null,
        ),
        if (isOtherSelected) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: otherController,
            decoration: const InputDecoration(
              labelText: 'Other Occupation',
              hintText: 'Write your occupation',
              prefixIcon: Icon(Icons.edit_outlined),
            ),
            validator: (v) {
              if (!isOtherSelected) return null;
              if (v == null || v.trim().isEmpty) {
                return 'Please write your occupation';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}

class _IncomeField extends StatelessWidget {
  const _IncomeField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
