import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/widgets/document_sample_preview.dart';
import 'package:provider/provider.dart';

class ApplyCardScreen extends StatefulWidget {
  const ApplyCardScreen({super.key, this.initialCardTypeId});

  final String? initialCardTypeId;

  @override
  State<ApplyCardScreen> createState() => _ApplyCardScreenState();
}

class _ApplyCardScreenState extends State<ApplyCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentsKey = GlobalKey();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _pickedFiles = {};
  final Map<String, String> _pickedFilePaths = {};
  final Map<String, String> _choiceValues = {};
  final Set<String> _missingDocuments = {};
  final Set<String> _uploadingDocuments = {};

  String? _selectedCardTypeId;
  bool _requirementsAccepted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCardTypeId = widget.initialCardTypeId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadCardTypes();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String key) {
    return _controllers.putIfAbsent(key, TextEditingController.new);
  }

  ({IconData icon, Color color}) _styleFor(CardTypeCode code) {
    switch (code) {
      case CardTypeCode.farmer:
        return (
          icon: Icons.agriculture_rounded,
          color: const Color(0xFF059669),
        );
      case CardTypeCode.family:
        return (
          icon: Icons.family_restroom_rounded,
          color: const Color(0xFF2563EB),
        );
      case CardTypeCode.education:
        return (icon: Icons.school_rounded, color: const Color(0xFF7C3AED));
    }
  }

  List<_ApplicationField> _fieldsFor(CardType cardType) {
    return cardType.applicationFields
        .where((field) => field.key.isNotEmpty && field.label.isNotEmpty)
        .map(_ApplicationField.fromConfig)
        .toList();
  }

  CardType? _selectedCardType(ApplicationProvider provider) {
    for (final cardType in provider.cardTypes) {
      if (cardType.id == _selectedCardTypeId) return cardType;
    }
    return null;
  }

  bool _hasDocument(String docType) {
    return _pickedFilePaths[docType]?.isNotEmpty == true;
  }

  List<String> _missingDocs(CardType cardType) {
    return _requiredDocumentsFor(
      cardType,
    ).where((docType) => !_hasDocument(docType)).toList();
  }

  List<String> _requiredDocumentsFor(CardType cardType) {
    return cardType.requiredDocuments;
  }

  List<String> _allowedExtensionsFor(String docType) {
    if (docType == 'recent_photo') return const ['jpg', 'jpeg'];
    return const ['pdf'];
  }

  String _formatRequirementFor(String docType) {
    final extensions = _allowedExtensionsFor(
      docType,
    ).map((extension) => extension.toUpperCase()).join('/');
    return context.trsp('extensions_only_format', {'ext': extensions});
  }

  String _documentLabelFor(CardType cardType, String docType) {
    return documentTypeLabel(docType);
  }

  String _criteriaFor(CardType cardType) {
    return cardType.eligibilityCriteria;
  }

  bool _isFarmerAddressComplete() {
    return const [
      'division',
      'district',
      'upazila',
      'local_body',
      'ward',
    ].every((key) => _choiceValues[key]?.trim().isNotEmpty == true);
  }

  void _clearApplicationInput() {
    _pickedFiles.clear();
    _pickedFilePaths.clear();
    _choiceValues.clear();
    _missingDocuments.clear();
    for (final controller in _controllers.values) {
      controller.clear();
    }
  }

  /// Seeds application fields with matching profile data already collected
  /// at registration/profile-completion, so the citizen isn't asked to
  /// retype it — only fields the controller doesn't already hold a value
  /// for are touched, so it never overwrites something the citizen typed.
  void _prefillFromProfile(CardType cardType) {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final prefix = cardType.code.name;

    void setText(String key, String? value) {
      if (value == null || value.isEmpty) return;
      final controller = _controllerFor('${prefix}_$key');
      if (controller.text.isEmpty) controller.text = value;
    }

    void setChoice(String key, String? value) {
      if (value == null || value.isEmpty) return;
      final storeKey = '${prefix}_$key';
      if ((_choiceValues[storeKey] ?? '').isEmpty) {
        _choiceValues[storeKey] = value;
        _controllerFor(storeKey).text = value;
      }
    }

    final dob = user.dateOfBirth == null
        ? null
        : DateFormat('dd/MM/yyyy').format(user.dateOfBirth!);

    switch (cardType.code) {
      case CardTypeCode.farmer:
      case CardTypeCode.family:
        setText('first_name', user.firstName);
        setText('last_name', user.lastName);
        setText('nid_card_number', user.nid);
        setText('date_of_birth', dob);
        setText('phone_number', user.phone);
        setText('village_road', user.address);
        if (cardType.code == CardTypeCode.farmer) {
          setText('cultivated_land_amount', user.landAcres?.toString());
          if (user.landAcres != null) setChoice('land_unit', 'Acre');
        } else {
          setText('monthly_income', user.income?.toString());
        }
      case CardTypeCode.education:
        setText('student_first_name', user.firstName);
        setText('student_last_name', user.lastName);
        setText('date_of_birth', dob);
        setText('nid_birth_certificate_number', user.nid);
    }
  }

  void _changeCard() {
    setState(() {
      _selectedCardTypeId = null;
      _requirementsAccepted = false;
      _clearApplicationInput();
    });
  }

  Future<void> _pickAndUploadDocument(String docType) async {
    final allowedExtensions = _allowedExtensionsFor(docType);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    final path = result?.files.single.path;
    final name = result?.files.single.name;
    if (path == null || name == null) return;
    if (!mounted) return;

    setState(() => _uploadingDocuments.add(docType));

    final provider = context.read<ApplicationProvider>();
    final success = await provider.uploadDocument(
      docType: docType,
      filePath: path,
    );
    if (!mounted) return;
    setState(() {
      _uploadingDocuments.remove(docType);
      if (success) {
        _pickedFiles[docType] = name;
        _pickedFilePaths[docType] = path;
        _missingDocuments.remove(docType);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.trs('document_uploaded_success')
              : provider.error ?? context.trs('upload_failed_generic'),
        ),
        backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
      ),
    );
  }

  void _showRequirements(CardType cardType) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.trsp('card_requirements_title', {'name': cardType.name}),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_criteriaFor(cardType)),
            const SizedBox(height: 16),
            Text(
              context.trs('documents_required_label'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              context.trs('tap_to_see_sample_hint'),
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ..._requiredDocumentsFor(cardType).map(
              (docType) => InkWell(
                onTap: () => showDocumentSample(dialogContext, docType),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_rounded,
                        size: 17,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_documentLabelFor(cardType, docType)} (${_formatRequirementFor(docType)})',
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            showDocumentSample(dialogContext, docType),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        color: AppTheme.primaryGreen,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.trs('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              final isNewCard = _selectedCardTypeId != cardType.id;
              setState(() {
                if (isNewCard) _clearApplicationInput();
                _selectedCardTypeId = cardType.id;
                _requirementsAccepted = true;
                if (isNewCard) _prefillFromProfile(cardType);
              });
            },
            child: Text(context.trs('proceed_action')),
          ),
        ],
      ),
    );
  }

  void _showPreview(CardType cardType) {
    final fields = _fieldsFor(cardType);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.trs('application_preview_title')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _PreviewRow(
                label: context.trs('card_type_label'),
                value: cardType.name,
              ),
              const Divider(height: 24),
              ...fields.map((field) {
                final controller = _controllerFor(
                  '${cardType.code.name}_${field.key}',
                );
                return _PreviewRow(
                  label: field.label,
                  value: controller.text.trim().isEmpty
                      ? context.trs('not_filled_value')
                      : controller.text.trim(),
                );
              }),
              if (cardType.code == CardTypeCode.farmer ||
                  cardType.code == CardTypeCode.family) ...[
                _PreviewRow(
                  label: context.trs('division_label'),
                  value:
                      _choiceValues['division'] ??
                      context.trs('not_selected_value'),
                ),
                _PreviewRow(
                  label: context.trs('district_label'),
                  value:
                      _choiceValues['district'] ??
                      context.trs('not_selected_value'),
                ),
                _PreviewRow(
                  label: context.trs('upazila_label'),
                  value:
                      _choiceValues['upazila'] ??
                      context.trs('not_selected_value'),
                ),
                _PreviewRow(
                  label: context.trs('union_label'),
                  value:
                      _choiceValues['local_body'] ??
                      context.trs('not_selected_value'),
                ),
                _PreviewRow(
                  label: context.trs('ward_number_label'),
                  value:
                      _choiceValues['ward'] ?? context.trs('not_selected_value'),
                ),
              ],
              const Divider(height: 24),
              ..._requiredDocumentsFor(cardType).map((docType) {
                return _DocumentPreviewRow(
                  label: _documentLabelFor(cardType, docType),
                  fileName: _pickedFiles[docType],
                  filePath: _pickedFilePaths[docType],
                );
              }),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.trs('back_to_form_action')),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final provider = context.read<ApplicationProvider>();
    final selectedType = _selectedCardType(provider);
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trs('please_select_card_type')),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (!_requirementsAccepted) {
      _showRequirements(selectedType);
      return;
    }

    final missing = _missingDocs(selectedType);
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _missingDocuments
        ..clear()
        ..addAll(missing);
    });

    if (missing.isNotEmpty) {
      Scrollable.ensureVisible(
        _documentsKey.currentContext ?? context,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trs('please_upload_all_documents')),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (!formValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trs('please_complete_all_fields')),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if ((selectedType.code == CardTypeCode.farmer ||
            selectedType.code == CardTypeCode.family) &&
        !_isFarmerAddressComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trs('please_select_address_fields')),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final applicationData = <String, String>{
      for (final field in _fieldsFor(selectedType))
        field.key:
            _choiceValues['${selectedType.code.name}_${field.key}'] ??
            _controllerFor('${selectedType.code.name}_${field.key}').text.trim(),
      for (final entry in _choiceValues.entries)
        if (!entry.key.startsWith('${selectedType.code.name}_')) entry.key: entry.value,
    };
    final success = await provider.submitApplication(
      cardTypeId: selectedType.id,
      applicationData: applicationData,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trs('application_submitted_success')),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      context.go('/citizen/applications');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? context.trs('application_submit_failed'),
          ),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();
    final selectedType = _selectedCardType(provider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: Text(context.tr('apply_for_card_title'))),
      body: provider.isLoading && provider.cardTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    context.tr('select_card_title'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (selectedType == null)
                    ...provider.cardTypes.map((cardType) {
                      final style = _styleFor(cardType.code);
                      return _CardTypeTile(
                        cardType: cardType,
                        icon: style.icon,
                        color: style.color,
                        selected: false,
                        onTap: () => _showRequirements(cardType),
                      );
                    })
                  else ...[
                    _SelectedCardHeader(
                      cardType: selectedType,
                      icon: _styleFor(selectedType.code).icon,
                      color: _styleFor(selectedType.code).color,
                      onChange: _changeCard,
                    ),
                  ],
                  if (selectedType != null && _requirementsAccepted) ...[
                    const SizedBox(height: 12),
                    _SectionHeader(
                      title: context.trp('application_form_title', {
                        'name': selectedType.name,
                      }),
                      subtitle: context.tr('fill_details_subtitle'),
                    ),
                    const SizedBox(height: 12),
                    ..._fieldsFor(selectedType).expand((field) {
                      final widgets = <Widget>[];
                      if (selectedType.code == CardTypeCode.education &&
                          field.key == 'ssc_institute_eiin') {
                        widgets.add(
                          _SubsectionHeader(
                            title: context.tr('ssc_exam_info_title'),
                          ),
                        );
                      }
                      if (selectedType.code == CardTypeCode.education &&
                          field.key == 'hsc_institute_eiin') {
                        widgets.add(
                          _SubsectionHeader(
                            title: context.tr('hsc_exam_info_title'),
                          ),
                        );
                      }
                      widgets.add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ApplicationFieldInput(
                            field: field,
                            controller: _controllerFor(
                              '${selectedType.code.name}_${field.key}',
                            ),
                            value:
                                _choiceValues['${selectedType.code.name}_${field.key}'],
                            onChanged: (value) {
                              setState(() {
                                _choiceValues['${selectedType.code.name}_${field.key}'] =
                                    value;
                              });
                            },
                          ),
                        ),
                      );
                      return widgets;
                    }),
                    if (selectedType.code == CardTypeCode.farmer ||
                        selectedType.code == CardTypeCode.family) ...[
                      _FarmerAddressFields(
                        values: _choiceValues,
                        onChanged: (key, value) {
                          setState(() {
                            _choiceValues[key] = value;
                            if (key == 'division') {
                              _choiceValues.remove('division_id');
                              _choiceValues.remove('district');
                              _choiceValues.remove('district_id');
                              _choiceValues.remove('upazila');
                              _choiceValues.remove('upazila_id');
                              _choiceValues.remove('local_body');
                              _choiceValues.remove('local_body_id');
                              _choiceValues.remove('ward');
                            } else if (key == 'district') {
                              _choiceValues.remove('district_id');
                              _choiceValues.remove('upazila');
                              _choiceValues.remove('upazila_id');
                              _choiceValues.remove('local_body');
                              _choiceValues.remove('local_body_id');
                              _choiceValues.remove('ward');
                            } else if (key == 'upazila') {
                              _choiceValues.remove('upazila_id');
                              _choiceValues.remove('local_body');
                              _choiceValues.remove('local_body_id');
                              _choiceValues.remove('ward');
                            } else if (key == 'local_body') {
                              _choiceValues.remove('local_body_id');
                              _choiceValues.remove('ward');
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 10),
                    _SectionHeader(
                      key: _documentsKey,
                      title: context.tr('required_documents_title'),
                      subtitle: context.tr(
                        'upload_preview_documents_subtitle',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._requiredDocumentsFor(selectedType).map(
                      (docType) => _DocumentRequirementTile(
                        label: _documentLabelFor(selectedType, docType),
                        formatLabel: _formatRequirementFor(docType),
                        pickedFileName: _pickedFiles[docType],
                        pickedFilePath: _pickedFilePaths[docType],
                        isMissing: _missingDocuments.contains(docType),
                        isUploading: _uploadingDocuments.contains(docType),
                        onUpload: () => _pickAndUploadDocument(docType),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _showPreview(selectedType),
                      icon: const Icon(Icons.visibility_rounded),
                      label: Text(context.tr('preview_application_action')),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
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
                        _isSubmitting
                            ? context.tr('submitting_label')
                            : context.tr('submit_application_action'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ApplicationField {
  const _ApplicationField(
    this.key,
    this.label, {
    this.keyboardType,
    this.hintText,
    this.options = const [],
    required this.required,
  });

  factory _ApplicationField.fromConfig(CardTypeApplicationField config) {
    return _ApplicationField(
      config.key,
      config.label,
      hintText: config.hintText,
      options: config.options,
      required: config.required,
      keyboardType: switch (config.inputType?.toLowerCase()) {
        'number' || 'numeric' || 'decimal' => TextInputType.number,
        'phone' => TextInputType.phone,
        'date' => TextInputType.datetime,
        'email' => TextInputType.emailAddress,
        _ => TextInputType.text,
      },
    );
  }

  final String key;
  final String label;
  final TextInputType? keyboardType;
  final String? hintText;
  final List<String> options;
  final bool required;
}

class _ApplicationFieldInput extends StatelessWidget {
  const _ApplicationFieldInput({
    required this.field,
    required this.controller,
    required this.value,
    required this.onChanged,
  });

  final _ApplicationField field;
  final TextEditingController controller;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = field.options;
    if (options.isNotEmpty) {
      return DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: field.label,
          prefixIcon: const Icon(Icons.touch_app_rounded),
        ),
        items: options
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        onChanged: (selected) {
          if (selected == null) return;
          controller.text = selected;
          onChanged(selected);
        },
        validator: (selected) {
          if (field.required && (selected == null || selected.trim().isEmpty)) {
            return context.trs('field_required_full');
          }
          return null;
        },
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: field.keyboardType,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.hintText,
        prefixIcon: const Icon(Icons.edit_note_rounded),
      ),
      validator: (value) {
        if (field.required && (value == null || value.trim().isEmpty)) {
          return context.trs('field_required_full');
        }
        return null;
      },
    );
  }
}

class _SubsectionHeader extends StatelessWidget {
  const _SubsectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.school_rounded,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerAddressFields extends StatefulWidget {
  const _FarmerAddressFields({required this.values, required this.onChanged});

  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  @override
  State<_FarmerAddressFields> createState() => _FarmerAddressFieldsState();
}

class _FarmerAddressFieldsState extends State<_FarmerAddressFields> {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://bdopenapi.vercel.app/api/geo',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  late final Future<_BangladeshGeoData> _geoFuture = _loadGeoData();

  Future<_BangladeshGeoData> _loadGeoData() async {
    final responses = await Future.wait([
      _dio.get('/divisions'),
      _dio.get('/districts'),
      _dio.get('/upazilas'),
      _dio.get('/unions'),
    ]);

    return _BangladeshGeoData(
      divisions: _locationsFrom(responses[0].data, parentKey: null),
      districts: _locationsFrom(responses[1].data, parentKey: 'division_id'),
      upazilas: _locationsFrom(responses[2].data, parentKey: 'district_id'),
      unions: _locationsFrom(responses[3].data, parentKey: 'upazila_id'),
    );
  }

  List<_GeoLocation> _locationsFrom(
    dynamic response, {
    required String? parentKey,
  }) {
    final data = response is Map ? response['data'] : null;
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map(
          (json) => _GeoLocation(
            id: json['id']?.toString() ?? '',
            parentId: parentKey == null ? null : json[parentKey]?.toString(),
            name: json['name']?.toString() ?? '',
            banglaName: json['bn_name']?.toString(),
          ),
        )
        .where((location) => location.id.isNotEmpty && location.name.isNotEmpty)
        .toList();
  }

  void _setLocation({
    required String nameKey,
    required String idKey,
    required _GeoLocation location,
  }) {
    widget.onChanged(nameKey, location.name);
    widget.onChanged(idKey, location.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BangladeshGeoData>(
      future: _geoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _LocationStatusBox(
            icon: Icons.hourglass_top_rounded,
            message: context.tr('loading_location_data'),
          );
        }

        final data = snapshot.data;
        if (snapshot.hasError || data == null || data.divisions.isEmpty) {
          return _LocationStatusBox(
            icon: Icons.cloud_off_rounded,
            message: context.tr('location_data_load_error'),
            isError: true,
          );
        }

        final districts = data.districtsFor(widget.values['division_id']);
        final upazilas = data.upazilasFor(widget.values['district_id']);
        final unions = data.unionsFor(widget.values['upazila_id']);

        return Column(
          children: [
            _AddressDropdown(
              label: context.tr('division_label'),
              selectedId: widget.values['division_id'],
              options: data.divisions,
              onChanged: (location) => _setLocation(
                nameKey: 'division',
                idKey: 'division_id',
                location: location,
              ),
            ),
            const SizedBox(height: 12),
            _AddressDropdown(
              label: context.tr('district_label'),
              selectedId: widget.values['district_id'],
              options: districts,
              onChanged: (location) => _setLocation(
                nameKey: 'district',
                idKey: 'district_id',
                location: location,
              ),
            ),
            const SizedBox(height: 12),
            _AddressDropdown(
              label: context.tr('upazila_label'),
              selectedId: widget.values['upazila_id'],
              options: upazilas,
              onChanged: (location) => _setLocation(
                nameKey: 'upazila',
                idKey: 'upazila_id',
                location: location,
              ),
            ),
            const SizedBox(height: 12),
            _AddressDropdown(
              label: context.tr('union_label'),
              selectedId: widget.values['local_body_id'],
              options: unions,
              onChanged: (location) => _setLocation(
                nameKey: 'local_body',
                idKey: 'local_body_id',
                location: location,
              ),
            ),
            const SizedBox(height: 12),
            _WardDropdown(
              value: widget.values['ward'],
              onChanged: (value) => widget.onChanged('ward', value),
            ),
          ],
        );
      },
    );
  }
}

class _BangladeshGeoData {
  const _BangladeshGeoData({
    required this.divisions,
    required this.districts,
    required this.upazilas,
    required this.unions,
  });

  final List<_GeoLocation> divisions;
  final List<_GeoLocation> districts;
  final List<_GeoLocation> upazilas;
  final List<_GeoLocation> unions;

  List<_GeoLocation> districtsFor(String? divisionId) {
    if (divisionId == null) return const [];
    return districts
        .where((location) => location.parentId == divisionId)
        .toList();
  }

  List<_GeoLocation> upazilasFor(String? districtId) {
    if (districtId == null) return const [];
    return upazilas
        .where((location) => location.parentId == districtId)
        .toList();
  }

  List<_GeoLocation> unionsFor(String? upazilaId) {
    if (upazilaId == null) return const [];
    return unions.where((location) => location.parentId == upazilaId).toList();
  }
}

class _GeoLocation {
  const _GeoLocation({
    required this.id,
    required this.parentId,
    required this.name,
    required this.banglaName,
  });

  final String id;
  final String? parentId;
  final String name;
  final String? banglaName;

  String get displayName {
    if (banglaName == null || banglaName!.isEmpty) return name;
    return '$name (${banglaName!})';
  }
}

class _AddressDropdown extends StatelessWidget {
  const _AddressDropdown({
    required this.label,
    required this.selectedId,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? selectedId;
  final List<_GeoLocation> options;
  final ValueChanged<_GeoLocation> onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = options.isNotEmpty;
    final selectedValue =
        enabled && options.any((option) => option.id == selectedId)
        ? selectedId
        : null;

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_on_rounded),
      ),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option.id,
              child: Text(option.displayName),
            ),
          )
          .toList(),
      onChanged: enabled
          ? (selected) {
              if (selected == null) return;
              final location = options.firstWhere(
                (option) => option.id == selected,
              );
              onChanged(location);
            }
          : null,
      validator: (selected) {
        if (selected == null || selected.trim().isEmpty) {
          return context.trs('field_required_full');
        }
        return null;
      },
    );
  }
}

class _WardDropdown extends StatelessWidget {
  const _WardDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: context.tr('ward_number_label'),
        prefixIcon: const Icon(Icons.location_on_rounded),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.trs('field_required_full');
        }
        return null;
      },
    );
  }
}

class _LocationStatusBox extends StatelessWidget {
  const _LocationStatusBox({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppTheme.errorRed : AppTheme.primaryGreen;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _CardTypeTile extends StatelessWidget {
  const _CardTypeTile({
    required this.cardType,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final CardType cardType;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppTheme.divider,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected ? null : AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardType.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.trp('documents_required_count', {
                      'count': '${cardType.requiredDocuments.length}',
                    }),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? color : AppTheme.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedCardHeader extends StatelessWidget {
  const _SelectedCardHeader({
    required this.cardType,
    required this.icon,
    required this.color,
    required this.onChange,
  });

  final CardType cardType;
  final IconData icon;
  final Color color;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardType.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cardType.requiredDocuments.length} documents required',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: Text(context.tr('change_action'))),
        ],
      ),
    );
  }
}

class _DocumentRequirementTile extends StatelessWidget {
  const _DocumentRequirementTile({
    required this.label,
    required this.formatLabel,
    required this.pickedFileName,
    required this.pickedFilePath,
    required this.isMissing,
    required this.isUploading,
    required this.onUpload,
  });

  final String label;
  final String formatLabel;
  final String? pickedFileName;
  final String? pickedFilePath;
  final bool isMissing;
  final bool isUploading;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final hasDocument = pickedFilePath?.isNotEmpty == true;
    final statusColor = isMissing
        ? AppTheme.errorRed
        : hasDocument
        ? AppTheme.successGreen
        : AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMissing ? AppTheme.errorRed : AppTheme.divider,
          width: isMissing ? 1.5 : 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Icon(
            hasDocument
                ? Icons.check_circle_rounded
                : Icons.upload_file_rounded,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pickedFileName ??
                      (hasDocument
                          ? context.tr('uploaded_document_available')
                          : context.trp('blank_required_option', {
                              'format': formatLabel,
                            })),
                  style: TextStyle(
                    fontSize: 12,
                    color: isMissing
                        ? AppTheme.errorRed
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: hasDocument
                ? context.tr('preview_document_tooltip')
                : context.tr('preview_unavailable_tooltip'),
            onPressed: hasDocument
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.trsp('opening_preview_for', {'label': label}),
                        ),
                      ),
                    );
                    _showDocumentPreview(
                      context,
                      label: label,
                      fileName:
                          pickedFileName ??
                          context.trs('selected_document_fallback'),
                      filePath: pickedFilePath!,
                    );
                  }
                : null,
            icon: const Icon(Icons.visibility_rounded),
          ),
          IconButton(
            tooltip: hasDocument
                ? context.tr('replace_document_tooltip')
                : context.tr('upload_document_tooltip'),
            onPressed: isUploading ? null : onUpload,
            icon: isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(hasDocument ? Icons.upload_rounded : Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

void _showDocumentPreview(
  BuildContext context, {
  required String label,
  required String fileName,
  required String filePath,
}) {
  final extension = fileName.split('.').last.toLowerCase();
  final isImage = const {'jpg', 'jpeg', 'png'}.contains(extension);
  final isPdf = extension == 'pdf';

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isImage)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(filePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _DocumentFileSummary(
                          icon: Icons.broken_image_rounded,
                          title: context.tr('preview_unavailable_tooltip'),
                        );
                      },
                    ),
                  ),
                )
              else if (isPdf)
                _PdfPagePreview(filePath: filePath)
              else
                _DocumentFileSummary(
                  icon: Icons.description_rounded,
                  title: context.tr('file_selected_label'),
                ),
              const SizedBox(height: 14),
              Text(
                fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                filePath,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(context.tr('close_preview_action')),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _DocumentFileSummary extends StatelessWidget {
  const _DocumentFileSummary({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppTheme.primaryGreen),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

const _documentPreviewChannel = MethodChannel(
  'bd.onecitizen.onecitizen/document_preview',
);

Future<Uint8List> _renderPdfFirstPage(String filePath) async {
  final bytes = await _documentPreviewChannel.invokeMethod<Uint8List>(
    'renderPdfFirstPage',
    {'path': filePath},
  );
  if (bytes == null || bytes.isEmpty) {
    throw StateError('No PDF preview was returned.');
  }
  return bytes;
}

class _PdfPagePreview extends StatelessWidget {
  const _PdfPagePreview({required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _renderPdfFirstPage(filePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _DocumentFileSummary(
            icon: Icons.hourglass_top_rounded,
            title: context.tr('loading_pdf_preview'),
          );
        }

        final bytes = snapshot.data;
        if (snapshot.hasError || bytes == null) {
          return _DocumentFileSummary(
            icon: Icons.picture_as_pdf_rounded,
            title: context.tr('pdf_preview_unavailable'),
          );
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentPreviewRow extends StatelessWidget {
  const _DocumentPreviewRow({
    required this.label,
    required this.fileName,
    required this.filePath,
  });

  final String label;
  final String? fileName;
  final String? filePath;

  @override
  Widget build(BuildContext context) {
    final name = fileName;
    final path = filePath;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (name == null || path == null)
            Text(
              context.trs('missing_value'),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.errorRed,
              ),
            )
          else
            GestureDetector(
              onTap: () => _showDocumentPreview(
                context,
                label: label,
                fileName: name,
                filePath: path,
              ),
              child: _DocumentThumbnail(fileName: name, filePath: path),
            ),
        ],
      ),
    );
  }
}

class _DocumentThumbnail extends StatelessWidget {
  const _DocumentThumbnail({required this.fileName, required this.filePath});

  final String fileName;
  final String filePath;

  @override
  Widget build(BuildContext context) {
    final extension = fileName.split('.').last.toLowerCase();
    final isImage = const {'jpg', 'jpeg', 'png'}.contains(extension);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        color: AppTheme.surfaceLight,
        child: isImage
            ? Image.file(
                File(filePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_rounded,
                  color: AppTheme.textTertiary,
                ),
              )
            : _PdfThumbnail(filePath: filePath),
      ),
    );
  }
}

class _PdfThumbnail extends StatelessWidget {
  const _PdfThumbnail({required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _renderPdfFirstPage(filePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final bytes = snapshot.data;
        if (snapshot.hasError || bytes == null) {
          return const Icon(
            Icons.picture_as_pdf_rounded,
            color: AppTheme.primaryGreen,
          );
        }
        return Image.memory(bytes, fit: BoxFit.cover);
      },
    );
  }
}
