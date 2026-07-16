import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/screens/citizen/my_applications_screen.dart' show statusColor;
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

/// Header icon that opens a quick NID / Application ID search — lets an
/// admin jump straight to a specific application from anywhere in the
/// admin section instead of paging through the full applications list.
class AdminQuickSearchButton extends StatelessWidget {
  const AdminQuickSearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search_rounded),
      tooltip: 'Search by NID or Application ID',
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _AdminSearchSheet(),
      ),
    );
  }
}

class _AdminSearchSheet extends StatefulWidget {
  const _AdminSearchSheet();

  @override
  State<_AdminSearchSheet> createState() => _AdminSearchSheetState();
}

class _AdminSearchSheetState extends State<_AdminSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    final provider = context.read<AdminProvider>();
    if (provider.applications.isEmpty && !provider.isLoadingApplications) {
      provider.loadApplications();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openApplication(String id) {
    Navigator.of(context).pop();
    context.push('/admin/applications/$id');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final query = _query.trim().toLowerCase();
    final results = query.isEmpty
        ? const <Application>[]
        : provider.applications
            .where((a) =>
                a.id.toLowerCase().contains(query) ||
                (a.applicantNid?.toLowerCase().contains(query) ?? false))
            .toList();

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Search Applications',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Enter NID or Application ID',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => setState(() {
                              _controller.clear();
                              _query = '';
                            }),
                          ),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(provider, query, results)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AdminProvider provider, String query, List<Application> results) {
    if (query.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Type an NID or Application ID to search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    if (provider.isLoadingApplications && provider.applications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, color: AppTheme.textSecondary, size: 36),
              const SizedBox(height: 12),
              const Text(
                'No matching applications found.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _openApplication(query),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Open Application ID exactly as typed'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final app = results[index];
        final color = statusColor(app.status);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.assignment_rounded, color: color, size: 20),
            ),
            title: Text(
              '${app.applicantName ?? 'Unknown'} — ${app.cardTypeName}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            subtitle: Text('ID: ${app.id} • NID: ${app.applicantNid ?? '-'}'),
            trailing: StatusBadge(label: app.status.name, color: color),
            onTap: () => _openApplication(app.id),
          ),
        );
      },
    );
  }
}
