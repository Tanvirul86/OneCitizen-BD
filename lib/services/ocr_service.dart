import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  Future<Map<String, String>> scanNid(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognizedText = await _recognizer.processImage(inputImage);
    final fullText = recognizedText.text;

    final result = <String, String>{};

    final nidMatch = RegExp(r'\b\d{10}\b|\b\d{13}\b|\b\d{17}\b').firstMatch(fullText);
    if (nidMatch != null) {
      result['nid'] = nidMatch.group(0)!;
    }

    final lines = fullText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    for (final line in lines) {
      if (line.toLowerCase().contains('name') && lines.length > 1) {
        final idx = lines.indexOf(line);
        if (idx + 1 < lines.length) {
          result['full_name'] = lines[idx + 1].trim();
        }
      }
    }

    return result;
  }

  void dispose() {
    _recognizer.close();
  }
}
