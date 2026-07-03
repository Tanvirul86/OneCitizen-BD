import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class CitizenAccountsScreen extends StatefulWidget {
  const CitizenAccountsScreen({super.key});

  @override
  State<CitizenAccountsScreen> createState() => _CitizenAccountsScreenState();
}

class _CitizenAccountsScreenState extends State<CitizenAccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCitizens();
    });
  }

  Future<void> _confirmDeactivate(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: Text('Deactivate $name\'s account? They will no longer be able to log in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AdminProvider>().deactivateCitizen(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or NID',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (v) => context.read<AdminProvider>().loadCitizens(search: v),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadCitizens(),
              child: provider.isLoadingCitizens
                  ? const Center(child: CircularProgressIndicator())
                  : provider.citizensError != null
                      ? ErrorMessage(message: provider.citizensError!, onRetry: () => provider.loadCitizens())
                      : provider.citizens.isEmpty
                          ? const EmptyListMessage(message: 'No citizen accounts found.', icon: Icons.people_outline)
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: provider.citizens.length,
                              itemBuilder: (context, index) {
                                final citizen = provider.citizens[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: citizen.isActive ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                      child: Icon(Icons.person, color: citizen.isActive ? AppTheme.primaryGreen : Colors.red),
                                    ),
                                    title: Text(citizen.fullName.isNotEmpty ? citizen.fullName : citizen.email, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    subtitle: Text('NID: ${citizen.nid ?? '-'} • ${citizen.email}'),
                                    trailing: citizen.isActive
                                        ? TextButton(
                                            onPressed: () => _confirmDeactivate(citizen.id, citizen.fullName),
                                            child: const Text('Deactivate', style: TextStyle(color: Colors.red)),
                                          )
                                        : const Text('Inactive', style: TextStyle(color: Colors.red)),
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
