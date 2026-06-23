import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/widgets/document_picker.dart';
import 'package:provider/provider.dart';

class ApplyCardScreen extends StatefulWidget {
  const ApplyCardScreen({super.key, this.initialCardTypeId});

  final String? initialCardTypeId;

  @override
  State<ApplyCardScreen> createState() => _ApplyCardScreenState();
}

class _ApplyCardScreenState extends State<ApplyCardScreen> {
  String? _selectedCardTypeId;
  final Map<String, String> _pickedDocuments = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCardTypeId = widget.initialCardTypeId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadCardTypes();
    });
  }

  void _onDocumentPicked(String documentType, String? filePath) {
    if (filePath != null) {
      _pickedDocuments[documentType] = filePath;
    } else {
      _pickedDocuments.remove(documentType);
    }
  }

  Future<void> _submitApplication() async {
    if (_selectedCardTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a card type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cardType = context
        .read<ApplicationProvider>()
        .cardTypes
        .firstWhere((element) => element.id == _selectedCardTypeId);

    if (cardType.requiredDocuments.any(
      (docType) => !_pickedDocuments.containsKey(docType),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await context.read<ApplicationProvider>().submitApplication(
          cardTypeId: _selectedCardTypeId!,
          documents: _pickedDocuments,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/citizen/tracker');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<ApplicationProvider>().error ??
                  'Failed to submit application',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();
    final selectedType = appProvider.cardTypes
        .where((element) => element.id == _selectedCardTypeId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Apply for New Card'),
      ),
      body: appProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Card Type',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCardTypeId,
                          decoration: const InputDecoration(
                            labelText: 'Card Type',
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Choose a card type'),
                          items: appProvider.cardTypes
                              .map(
                                (cardType) => DropdownMenuItem(
                                  value: cardType.id,
                                  child: Text(cardType.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCardTypeId = value;
                              _pickedDocuments.clear();
                            });
                          },
                          validator: (value) => value == null
                              ? 'Please select a card type'
                              : null,
                        ),
                        if (selectedType != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            selectedType.description ?? '',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Required Documents:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          if (selectedType.requiredDocuments.isEmpty)
                            const Text('No documents required.')
                          else
                            ...selectedType.requiredDocuments.map(
                              (docType) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: DocumentPicker(
                                  documentType: docType,
                                  onFilePicked: (documentType, filePath) =>
                                      _onDocumentPicked(documentType, filePath),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
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
                          'Submit Application',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
    );
  }
}
