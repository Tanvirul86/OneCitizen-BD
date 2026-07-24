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

  Future<void> _confirmFreeze(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Freeze Account'),
        content: Text('Freeze $name\'s account? They will be temporarily blocked until you unfreeze it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Freeze'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AdminProvider>().freezeCitizen(id);
    }
  }

  Future<void> _unfreeze(String id) async {
    await context.read<AdminProvider>().unfreezeCitizen(id);
  }

  Future<void> _confirmActivate(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Account'),
        content: Text('Activate $name\'s account? They will be able to log in again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AdminProvider>().activateCitizen(id);
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
                                final statusColor = !citizen.isActive
                                    ? Colors.red
                                    : citizen.isFrozen
                                        ? Colors.blue
                                        : AppTheme.primaryGreen;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: statusColor.withValues(alpha: 0.1),
                                      child: Icon(Icons.person, color: statusColor),
                                    ),
                                    title: Text(citizen.fullName.isNotEmpty ? citizen.fullName : citizen.email, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    subtitle: Text('NID: ${citizen.nid ?? '-'} • ${citizen.email}'),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (action) {
                                        switch (action) {
                                          case 'activate':
                                            _confirmActivate(citizen.id, citizen.fullName);
                                          case 'freeze':
                                            _confirmFreeze(citizen.id, citizen.fullName);
                                          case 'unfreeze':
                                            _unfreeze(citizen.id);
                                          case 'deactivate':
                                            _confirmDeactivate(citizen.id, citizen.fullName);
                                        }
                                      },
                                      itemBuilder: (context) => !citizen.isActive
                                          ? [const PopupMenuItem(value: 'activate', child: Text('Activate'))]
                                          : [
                                              if (citizen.isFrozen)
                                                const PopupMenuItem(value: 'unfreeze', child: Text('Unfreeze'))
                                              else
                                                const PopupMenuItem(value: 'freeze', child: Text('Freeze')),
                                              const PopupMenuItem(
                                                value: 'deactivate',
                                                child: Text('Deactivate', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!citizen.isActive)
                                            const _StatusBadge(label: 'Inactive', color: Colors.red)
                                          else if (citizen.isFrozen)
                                            const _StatusBadge(label: 'Frozen', color: Colors.blue),
                                          const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                                        ],
                                      ),
                                    ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
