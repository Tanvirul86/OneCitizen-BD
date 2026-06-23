import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nidController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _occupationController = TextEditingController();
  final _incomeController = TextEditingController();
  final _landHoldingController = TextEditingController();
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.fullName ?? '';
      _nidController.text = user.nid ?? '';
      _emailController.text = user.email ?? '';
      _addressController.text = user.address ?? '';
      _occupationController.text = user.occupation ?? '';
      _incomeController.text = user.income?.toString() ?? '';
      _landHoldingController.text = user.landHolding?.toString() ?? '';
      _dateOfBirth = user.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nidController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _incomeController.dispose();
    _landHoldingController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        await auth.uploadProfilePicture(image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
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
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.primaryGreen.withValues(alpha:0.1),
                      backgroundImage: user?.profilePictureUrl != null
                          ? NetworkImage(user!.profilePictureUrl!) as ImageProvider
                          : null,
                      child: user?.profilePictureUrl == null
                          ? const Icon(Icons.person, size: 60, color: AppTheme.primaryGreen)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryGreen,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20),
                          color: Colors.white,
                          onPressed: _pickProfilePicture,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nidController,
                decoration: const InputDecoration(
                  labelText: 'NID Number',
                  prefixIcon: Icon(Icons.credit_card_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'NID is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.calendar_today),
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
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(
                  labelText: 'Occupation',
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _incomeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Income (BDT)',
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landHoldingController,
                decoration: const InputDecoration(
                  labelText: 'Land Holding (Acres)',
                  prefixIcon: Icon(Icons.area_chart),
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
                        'Save Profile',
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
