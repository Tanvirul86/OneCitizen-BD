import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:provider/provider.dart';

class EligibilityScreen extends StatefulWidget {
  const EligibilityScreen({super.key});

  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _occupationController = TextEditingController();
  final _incomeController = TextEditingController();
  final _ageController = TextEditingController();
  final _landHoldingController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _occupationController.dispose();
    _incomeController.dispose();
    _ageController.dispose();
    _landHoldingController.dispose();
    super.dispose();
  }

  Future<void> _checkEligibility() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final appProvider = context.read<ApplicationProvider>();

    try {
      await appProvider.checkEligibility(
        occupation: _occupationController.text.trim(),
        income: double.parse(_incomeController.text.trim()),
        age: int.parse(_ageController.text.trim()),
        landHolding: _landHoldingController.text.isNotEmpty
            ? double.parse(_landHoldingController.text.trim())
            : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appProvider.error ?? 'Failed to check eligibility'),
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
    final appProvider = context.watch<ApplicationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Check Eligibility'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter your details to find eligible cards',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _occupationController,
                        decoration: const InputDecoration(
                          labelText: 'Occupation',
                          hintText: 'e.g., Farmer, Student, Employee',
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your occupation'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _incomeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Income (BDT)',
                          hintText: 'e.g., 25000',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your monthly income';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          hintText: 'e.g., 30',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid integer';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _landHoldingController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Land Holding (Acres) (Optional)',
                          hintText: 'e.g., 5.5',
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _checkEligibility,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Check Eligibility'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (appProvider.eligibilityResult != null) ...[
                const Text(
                  'Eligible Cards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (appProvider.eligibilityResult!.eligibleCards.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        appProvider.eligibilityResult!.message ??
                            'No cards found based on your criteria.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  ...appProvider.eligibilityResult!.eligibleCards.map(
                    (cardType) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        title: Text(cardType.name),
                        subtitle: Text(cardType.description ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.push(
                          '/citizen/apply',
                          extra: cardType.id,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                if (appProvider.eligibilityResult!.recommendations.isNotEmpty) ...[
                  const Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: appProvider.eligibilityResult!.recommendations
                            .map((rec) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text('- $rec'),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
