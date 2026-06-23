import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/application.dart';
import 'package:intl/intl.dart';

class ApplicationTimeline extends StatelessWidget {
  const ApplicationTimeline({super.key, required this.timeline});

  final List<ApplicationTimelineEntry> timeline;

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return const Center(child: Text('No timeline entries.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final entry = timeline[index];
        final isFirst = index == 0;
        final isLast = index == timeline.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 2,
                    height: 20,
                    color: isFirst ? Colors.transparent : AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: _getStatusColor(entry.status),
                    child: Icon(
                      _getStatusIcon(entry.status),
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isLast ? Colors.transparent : AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicationStatusToString(entry.status),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                                'dd MMM yyyy HH:mm'
                                ).format(entry.timestamp),
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      if (entry.remarks != null && entry.remarks!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            entry.remarks!,
                            style: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                          ),
                        ),
                      if (entry.officerName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'By: ${entry.officerName}',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.documentRequested:
        return Colors.orange;
      case ApplicationStatus.underReview:
        return Colors.blue;
      case ApplicationStatus.submitted:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
      case ApplicationStatus.documentRequested:
        return Icons.info;
      case ApplicationStatus.underReview:
        return Icons.hourglass_empty;
      case ApplicationStatus.submitted:
        return Icons.file_copy;
    }
  }
}
