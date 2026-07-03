import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _occupationController = TextEditingController();
  final _incomeController = TextEditingController();
  final _landController = TextEditingController();
  final _sscController = TextEditingController();
  final _hscController = TextEditingController();
  String? _gender;
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _addressController.text = user.address ?? '';
      _occupationController.text = user.occupation ?? '';
      _incomeController.text = user.income?.toString() ?? '';
      _landController.text = user.landAcres?.toString() ?? '';
      _sscController.text = user.sscGpa?.toString() ?? '';
      _hscController.text = user.hscGpa?.toString() ?? '';
      _gender = user.gender;
      _dateOfBirth = user.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _occupationController.dispose();
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
        const SnackBar(content: Text('Please select your date of birth'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final data = {
      'date_of_birth': DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
      'gender': _gender,
      'address': _addressController.text.trim(),
      'occupation': _occupationController.text.trim(),
      if (_incomeController.text.isNotEmpty) 'income': double.tryParse(_incomeController.text),
      if (_landController.text.isNotEmpty) 'land_acres': double.tryParse(_landController.text),
      if (_sscController.text.isNotEmpty) 'ssc_gpa': double.tryParse(_sscController.text),
      if (_hscController.text.isNotEmpty) 'hsc_gpa': double.tryParse(_hscController.text),
    };
    final success = await auth.updateProfile(data);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/citizen');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Failed to save profile'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        actions: [TextButton(onPressed: () => context.go('/citizen'), child: const Text('Skip', style: TextStyle(color: Colors.white)))],
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
                  border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppTheme.primaryGreen, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'These details are used to check your eligibility for the Farmer, Family, and Education cards.',
                        style: TextStyle(fontSize: 13, color: AppTheme.primaryGreen, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date of Birth', prefixIcon: Icon(Icons.calendar_today)),
                  child: Text(_dateOfBirth == null ? 'Select date' : DateFormat('dd MMM yyyy').format(_dateOfBirth!)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc)),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? 'Address is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(labelText: 'Occupation', prefixIcon: Icon(Icons.work)),
                validator: (v) => (v == null || v.isEmpty) ? 'Occupation is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _incomeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Household Income (BDT)', prefixIcon: Icon(Icons.money)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Land Owned (Acres)', prefixIcon: Icon(Icons.terrain)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sscController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'SSC GPA', prefixIcon: Icon(Icons.school)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hscController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'HSC GPA', prefixIcon: Icon(Icons.school_outlined)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
