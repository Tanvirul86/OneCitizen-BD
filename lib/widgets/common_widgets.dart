import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';

/// [profilePicture] may be a real URL or a local device file path (this app
/// has no media server, so uploaded profile photos are kept as on-device
/// file paths) — pick the right [ImageProvider] for either case.
ImageProvider? avatarImageFor(String? profilePicture) {
  if (profilePicture == null || profilePicture.isEmpty) return null;
  return profilePicture.startsWith('http')
      ? NetworkImage(profilePicture)
      : FileImage(File(profilePicture));
}

const _documentPreviewChannel = MethodChannel(
  'bd.onecitizen.onecitizen/document_preview',
);

/// Renders the first page of a locally-saved PDF to PNG bytes via the same
/// native channel the apply-for-card flow uses to preview a picked file
/// before upload.
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

/// Renders a document's `fileUrl`, which is either a `data:` URI (documents
/// are stored as base64 in the Realtime Database — there's no Firebase
/// Storage on the Spark plan) or, for anything not uploaded that way, a
/// regular network URL. PDFs stored as `data:` URIs are written to a temp
/// file and rendered via the native PDF-preview channel, since
/// `Image.memory` can only decode raster image bytes.
Widget documentImage(
  String fileUrl, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  if (fileUrl.startsWith('data:')) {
    final isPdf = fileUrl.startsWith('data:application/pdf');
    final bytes = () {
      try {
        return base64Decode(fileUrl.split(',').last);
      } catch (_) {
        return null;
      }
    }();
    if (bytes == null) {
      return Builder(
        builder: (context) =>
            errorBuilder?.call(
              context,
              StateError('Invalid document data.'),
              null,
            ) ??
            const Icon(Icons.broken_image),
      );
    }
    if (!isPdf) {
      return Image.memory(
        bytes,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }
    return FutureBuilder<Uint8List>(
      future: () async {
        final tempFile = await File(
          '${Directory.systemTemp.path}/doc_preview_${identityHashCode(fileUrl)}.pdf',
        ).writeAsBytes(bytes);
        return _renderPdfFirstPage(tempFile.path);
      }(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            height: height,
            width: width,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return errorBuilder?.call(
                context,
                snapshot.error ?? StateError('No preview'),
                null,
              ) ??
              const Icon(Icons.picture_as_pdf_rounded);
        }
        return Image.memory(
          snapshot.data!,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: errorBuilder,
        );
      },
    );
  }
  return Image.network(
    fileUrl,
    height: height,
    width: width,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}

/// Opens a full-screen, pinch-to-zoom preview of a document — shared by
/// every screen that lets a citizen or admin tap a document to view it.
void viewDocument(
  BuildContext context, {
  required String fileUrl,
  required String title,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(title),
        ),
        body: SafeArea(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 5,
            child: Center(
              child: documentImage(
                fileUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class EmptyListMessage extends StatelessWidget {
  const EmptyListMessage({
    super.key,
    required this.message,
    this.icon,
    this.onRetry,
  });

  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.info_outline,
            size: 60,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(
                  context.tr('try_again_action'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: AppTheme.accentRed.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.trp('error_prefix', {'message': message}),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: AppTheme.accentRed),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(
                  context.tr('try_again_action'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
