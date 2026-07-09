import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/screens/citizen/my_applications_screen.dart' show statusColor;
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

class NewApplicationsScreen extends StatefulWidget {
  const NewApplicationsScreen({super.key, this.initialCardTypeName});

  final String? initialCardTypeName;

  @override
  State<NewApplicationsScreen> createState() => _NewApplicationsScreenState();
}

class _NewApplicationsScreenState extends State<NewApplicationsScreen> {
  ApplicationStatus? _filter;
  String? _cardTypeFilter;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _cardTypeFilter = widget.initialCardTypeName;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadApplications();
    });
  }

  Future<void> _openApplication(String id) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    await context.push('/admin/applications/$id');
    if (mounted) setState(() => _isNavigating = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final filtered = provider.applications
        .where((a) => _filter == null || a.status == _filter)
        .where((a) => _cardTypeFilter == null || a.cardTypeName == _cardTypeFilter)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: Column(
        children: [
          if (_cardTypeFilter != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Showing "$_cardTypeFilter" applications',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _cardTypeFilter = null),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _Chip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                ...ApplicationStatus.values.map(
                  (s) => _Chip(
                    label: applicationStatusToString(s),
                    selected: _filter == s,
                    color: statusColor(s),
                    onTap: () => setState(() => _filter = s),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadApplications(),
              child: provider.isLoadingApplications
                  ? const Center(child: CircularProgressIndicator())
                  : provider.applicationsError != null
                      ? ErrorMessage(message: provider.applicationsError!, onRetry: () => provider.loadApplications())
                      : filtered.isEmpty
                          ? const EmptyListMessage(message: 'No applications found.', icon: Icons.assignment_outlined)
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final app = filtered[index];
                                final color = statusColor(app.status);
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.assignment_rounded, color: color, size: 22),
                                    ),
                                    title: Text('${app.applicantName ?? 'Unknown'} — ${app.cardTypeName}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    subtitle: Text('NID: ${app.applicantNid ?? '-'} • ${DateFormat('dd MMM yyyy').format(app.submittedAt)}'),
                                    trailing: StatusBadge(label: app.status.name, color: color),
                                    onTap: () => _openApplication(app.id),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap, this.color});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primaryGreen;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label.replaceAll('_', ' '), style: TextStyle(color: selected ? Colors.white : chipColor, fontWeight: FontWeight.w600, fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: chipColor,
        backgroundColor: chipColor.withValues(alpha: 0.1),
        checkmarkColor: Colors.white,
        side: BorderSide(color: chipColor.withValues(alpha: 0.4)),
        showCheckmark: false,
      ),
    );
  }
}
