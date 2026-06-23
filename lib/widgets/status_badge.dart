import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    this.status,
    this.label,
    this.color,
  }) : assert(status != null || label != null,
            'Either status or label must be provided');

  /// Auto-derive label text and color from this status string.
  final String? status;

  /// Override label text (falls back to [status] if null).
  final String? label;

  /// Override badge color (auto-derived from [status] if null).
  final Color? color;

  Color _getColor(String s) {
    switch (s.toLowerCase()) {
      case 'approved':
      case 'active':
      case 'resolved':
        return Colors.green;
      case 'rejected':
      case 'suspended':
        return Colors.red;
      case 'pending':
      case 'under_review':
      case 'document_requested':
      case 'in_progress':
        return Colors.orange;
      case 'submitted':
        return Colors.blue;
      case 'open':
        return Colors.purple;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? status!;
    final displayColor = color ?? _getColor(status ?? label!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: displayColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayLabel.replaceAll(
            RegExp(r'(_|(?<=[a-z])(?=[A-Z]))'), ' '),
        style: TextStyle(
          color: displayColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
