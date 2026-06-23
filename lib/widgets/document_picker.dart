import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';

class DocumentPicker extends StatefulWidget {
  const DocumentPicker({
    super.key,
    required this.documentType,
    required this.onFilePicked,
  });

  final String documentType;
  final Function(String documentType, String? filePath) onFilePicked;

  @override
  State<DocumentPicker> createState() => _DocumentPickerState();
}

class _DocumentPickerState extends State<DocumentPicker> {
  String? _fileName;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
        });
        widget.onFilePicked(widget.documentType, result.files.single.path);
      } else {
        widget.onFilePicked(widget.documentType, null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
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
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.documentType,
        border: const OutlineInputBorder(),
        suffixIcon: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.upload_file),
                onPressed: _pickFile,
              ),
      ),
      child: _fileName == null
          ? Text(
              'No file selected',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          : Text(_fileName!),
    );
  }
}
