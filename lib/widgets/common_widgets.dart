import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';

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
            color: AppTheme.textSecondary.withValues(alpha:0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
  });

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
            color: AppTheme.accentRed.withValues(alpha:0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.accentRed,
            ),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
