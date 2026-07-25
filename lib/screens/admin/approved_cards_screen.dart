import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class ApprovedCardsScreen extends StatefulWidget {
  const ApprovedCardsScreen({super.key});

  @override
  State<ApprovedCardsScreen> createState() => _ApprovedCardsScreenState();
}

class _ApprovedCardsScreenState extends State<ApprovedCardsScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadApplications(status: ApplicationStatus.approved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final approved = provider.applications
        .where((a) => a.status == ApplicationStatus.approved)
        .where((a) => _search.isEmpty || (a.applicantName ?? '').toLowerCase().contains(_search.toLowerCase()))
        .toList();

    final byCardType = <String, List<Application>>{};
    for (final app in approved) {
      byCardType.putIfAbsent(app.cardTypeName, () => []).add(app);
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(labelText: context.tr('search_by_citizen_name'), prefixIcon: const Icon(Icons.search)),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: provider.isLoadingApplications
                ? const Center(child: CircularProgressIndicator())
                : approved.isEmpty
                    ? EmptyListMessage(message: context.tr('no_approved_cards'), icon: Icons.credit_card_off)
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: byCardType.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '${entry.key} (${entry.value.length})',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                ),
                              ),
                              ...entry.value.map(
                                (app) => Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.successGreen.withValues(alpha: 0.1),
                                      child: const Icon(Icons.check_rounded, color: AppTheme.successGreen),
                                    ),
                                    title: Text(app.applicantName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    subtitle: Text(context.trp('nid_approved_date', {
                                      'nid': app.applicantNid ?? '-',
                                      'date': DateFormat('dd MMM yyyy').format(app.updatedAt ?? app.submittedAt),
                                    })),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}
