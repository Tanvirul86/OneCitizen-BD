import 'dart:io';

import 'package:flutter/material.dart';
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
