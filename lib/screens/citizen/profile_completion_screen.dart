import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/occupation.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/utils/numeric_input.dart';
import 'package:provider/provider.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _incomeController = TextEditingController();
  final _landController = TextEditingController();
  final _sscController = TextEditingController();
  final _hscController = TextEditingController();
  String? _gender;
  Occupation? _occupation;
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _addressController.text = user.address ?? '';
      _occupation = occupationFromString(user.occupation);
      _incomeController.text = user.income?.toString() ?? '';
      _landController.text = user.landAcres?.toString() ?? '';
      _sscController.text = user.sscGpa?.toString() ?? '';
      _hscController.text = user.hscGpa?.toString() ?? '';
      _gender = user.gender;
      _dateOfBirth = user.dateOfBirth;
    }
  }

  String? _numericValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value) == null
        ? context.trs('numbers_only_error')
        : null;
  }

  void _onOccupationChanged(Occupation? value) {
    setState(() {
      _occupation = value;
      if (value != Occupation.farmer) _landController.clear();
      if (value != Occupation.student) {
        _sscController.clear();
        _hscController.clear();
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _incomeController.dispose();
    _landController.dispose();
    _sscController.dispose();
    _hscController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _dateOfBirth = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trs('please_select_dob')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final data = {
      'date_of_birth': DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
      'gender': _gender,
      'address': _addressController.text.trim(),
      'occupation': occupationToString(_occupation!),
      if (_incomeController.text.isNotEmpty)
        'income': double.tryParse(_incomeController.text),
      if (_landController.text.isNotEmpty)
        'land_acres': double.tryParse(_landController.text),
      if (_sscController.text.isNotEmpty)
        'ssc_gpa': double.tryParse(_sscController.text),
      if (_hscController.text.isNotEmpty)
        'hsc_gpa': double.tryParse(_hscController.text),
    };
    final success = await auth.updateProfile(data);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/citizen');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ?? context.trs('failed_save_profile'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: Text(context.tr('complete_profile_title')),
        actions: [
          TextButton(
            onPressed: () => context.go('/citizen'),
            child: Text(
              context.tr('skip_action'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('profile_completion_hint'),
                        style: const TextStyle(
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
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.tr('date_of_birth_label'),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateOfBirth == null
                        ? context.tr('select_date_placeholder')
                        : DateFormat('dd MMM yyyy').format(_dateOfBirth!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: InputDecoration(
                  labelText: context.tr('gender_label'),
                  prefixIcon: const Icon(Icons.wc),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text(context.tr('gender_male')),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text(context.tr('gender_female')),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text(context.tr('gender_other')),
                  ),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: context.tr('address_label'),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty)
                    ? context.trs('address_required')
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Occupation>(
                initialValue: _occupation,
                decoration: InputDecoration(
                  labelText: context.tr('occupation_label'),
                  prefixIcon: const Icon(Icons.work),
                ),
                items: Occupation.values
                    .map(
                      (o) => DropdownMenuItem(
                        value: o,
                        child: Text(occupationLabel(o)),
                      ),
                    )
                    .toList(),
                onChanged: _onOccupationChanged,
                validator: (v) =>
                    v == null ? context.trs('occupation_required') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _incomeController,
                keyboardType: TextInputType.number,
                inputFormatters: decimalInputFormatters,
                validator: _numericValidator,
                decoration: InputDecoration(
                  labelText: context.tr('monthly_income_label'),
                  prefixIcon: const Icon(Icons.money),
                ),
              ),
              if (_occupation == Occupation.farmer) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _landController,
                  keyboardType: TextInputType.number,
                  inputFormatters: decimalInputFormatters,
                  validator: _numericValidator,
                  decoration: InputDecoration(
                    labelText: context.tr('land_owned_label'),
                    prefixIcon: const Icon(Icons.terrain),
                  ),
                ),
              ],
              if (_occupation == Occupation.student) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sscController,
                  keyboardType: TextInputType.number,
                  inputFormatters: decimalInputFormatters,
                  validator: _numericValidator,
                  decoration: InputDecoration(
                    labelText: context.tr('ssc_gpa_label'),
                    prefixIcon: const Icon(Icons.school),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hscController,
                  keyboardType: TextInputType.number,
                  inputFormatters: decimalInputFormatters,
                  validator: _numericValidator,
                  decoration: InputDecoration(
                    labelText: context.tr('hsc_gpa_label'),
                    prefixIcon: const Icon(Icons.school_outlined),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.tr('save_continue_action'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
