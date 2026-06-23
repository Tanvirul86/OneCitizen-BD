import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/providers/officer_provider.dart';
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  ApplicationStatus? _selectedStatusFilter;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfficerProvider>().loadApplications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      context.go('/login');
    }
  }

  void _onSearch() {
    context.read<OfficerProvider>().setSearchQuery(_searchController.text);
    context.read<OfficerProvider>().loadApplications(filter: _selectedStatusFilter);
  }

  @override
  Widget build(BuildContext context) {
    final officerProvider = context.watch<OfficerProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Officer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => officerProvider.loadApplications(filter: _selectedStatusFilter),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search Applications',
                            hintText: 'By ID, NID, or Name',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearch();
                                    },
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _onSearch(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _onSearch,
                        icon: const Icon(Icons.search),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ApplicationStatus>(
                    value: _selectedStatusFilter,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ApplicationStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(applicationStatusToString(status)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatusFilter = value;
                      });
                      officerProvider.loadApplications(filter: value);
                    },
                    hint: const Text('All Statuses'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: officerProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : officerProvider.applications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 60,
                                color: AppTheme.textSecondary.withValues(alpha:0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No applications found.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: officerProvider.applications.length,
                          itemBuilder: (context, index) {
                            final application = officerProvider.applications[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                    '${application.cardTypeName} Application'),
                                subtitle: Text(
                                    'Applicant: ${application.applicantName ?? 'N/A'}\nNID: ${application.applicantNid ?? 'N/A'}'),
                                isThreeLine: true,
                                trailing: StatusBadge(status: application.status.name),
                                onTap: () => context.push(
                                    '/officer/applications/${application.id}'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
