import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/config/routes.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/services/ocr_service.dart';
import 'package:provider/provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nidController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _occupationController = TextEditingController();
  final _incomeController = TextEditingController();
  final _landHoldingController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _profilePicturePath;
  bool _isLoading = false;
  final _ocrService = OcrService();

  @override
  void dispose() {
    _nameController.dispose();
    _nidController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _incomeController.dispose();
    _landHoldingController.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _scanNid() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await _ocrService.scanNid(image.path);
      if (data['nid'] != null) {
        _nidController.text = data['nid']!;
      }
      if (data['full_name'] != null) {
        _nameController.text = data['full_name']!;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NID scanned successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan NID: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profilePicturePath = image.path);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dateOfBirth = date);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    try {
      final data = {
        'full_name': _nameController.text.trim(),
        'nid': _nidController.text.trim(),
        if (_emailController.text.isNotEmpty)
          'email': _emailController.text.trim(),
        if (_addressController.text.isNotEmpty)
          'address': _addressController.text.trim(),
        if (_occupationController.text.isNotEmpty)
          'occupation': _occupationController.text.trim(),
        if (_dateOfBirth != null)
          'date_of_birth': DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
        if (_incomeController.text.isNotEmpty)
          'income': double.tryParse(_incomeController.text),
        if (_landHoldingController.text.isNotEmpty)
          'land_holding': double.tryParse(_landHoldingController.text),
      };

      final success = await auth.updateProfile(data);
      
      if (_profilePicturePath != null) {
        await auth.uploadProfilePicture(_profilePicturePath!);
      }

      if (mounted && success) {
        await auth.completeOnboarding();
        context.go(AppRouter.homeForRole(auth.user!.role));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Please provide your details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      child: _profilePicturePath == null
                          ? const Icon(Icons.person, size: 50, color: AppTheme.primaryGreen)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryGreen,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          color: Colors.white,
                          onPressed: _pickProfilePicture,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nidController,
                      decoration: const InputDecoration(
                        labelText: 'NID Number *',
                        hintText: 'Enter your NID',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'NID is required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _scanNid,
                    icon: const Icon(Icons.document_scanner),
                    tooltip: 'Scan NID',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter your full name',
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'your@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                  ),
                  child: Text(
                    _dateOfBirth == null
                        ? 'Select date'
                        : DateFormat('dd MMM yyyy').format(_dateOfBirth!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address (Optional)',
                  hintText: 'Your address',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(
                  labelText: 'Occupation (Optional)',
                  hintText: 'Your occupation',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _incomeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Income (BDT)',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landHoldingController,
                decoration: const InputDecoration(
                  labelText: 'Land Holding (Acres)',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                    : const Text(
                        'Complete Setup',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
