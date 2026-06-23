import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDisplay extends StatelessWidget {
  const QrDisplay({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: 200.0,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(16),
    );
  }
}
