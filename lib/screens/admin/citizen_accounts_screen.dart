import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class CitizenAccountsScreen extends StatefulWidget {
  const CitizenAccountsScreen({super.key});

  @override
  State<CitizenAccountsScreen> createState() => _CitizenAccountsScreenState();
}

class _CitizenAccountsScreenState extends State<CitizenAccountsScreen> {
  String? _selectedCardTypeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCitizens();
      context.read<AdminProvider>().loadApplications();
      context.read<ApplicationProvider>().loadCardTypes();
    });
  }

  ({IconData icon, Color color}) _styleFor(CardTypeCode code) {
    switch (code) {
      case CardTypeCode.farmer:
        return (
          icon: Icons.agriculture_rounded,
          color: const Color(0xFF059669),
        );
      case CardTypeCode.family:
        return (
          icon: Icons.family_restroom_rounded,
          color: const Color(0xFF2563EB),
        );
      case CardTypeCode.education:
        return (icon: Icons.school_rounded, color: const Color(0xFF7C3AED));
    }
  }

  Future<void> _confirmDeactivate(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.trs('deactivate_account_title')),
        content: Text(context.trsp('confirm_deactivate_body', {'name': name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.trs('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.trs('deactivate_action')),
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
      builder: (dialogContext) => AlertDialog(
        title: Text(context.trs('freeze_account_title')),
        content: Text(context.trsp('confirm_freeze_body', {'name': name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.trs('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text(context.trs('freeze_action')),
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
      builder: (dialogContext) => AlertDialog(
        title: Text(context.trs('activate_account_title')),
        content: Text(context.trsp('confirm_activate_body', {'name': name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.trs('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: Text(context.trs('activate_action')),
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
    final cardTypes = context.watch<ApplicationProvider>().cardTypes;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: _selectedCardTypeId == null
          ? _buildCardTypeSummary(provider, cardTypes)
          : _buildCitizenList(provider, cardTypes),
    );
  }

  Widget _buildCardTypeSummary(
    AdminProvider provider,
    List<CardType> cardTypes,
  ) {
    if (cardTypes.isEmpty || provider.isLoadingApplications) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadApplications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cardTypes.length,
        itemBuilder: (context, index) {
          final cardType = cardTypes[index];
          final citizenIds = provider.applications
              .where((a) => a.cardTypeId == cardType.id)
              .map((a) => a.applicantId)
              .whereType<String>()
              .toSet();
          final style = _styleFor(cardType.code);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _selectedCardTypeId = cardType.id),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: style.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(style.icon, color: style.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        cardType.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      context.trp('citizens_count_label', {
                        'count': '${citizenIds.length}',
                      }),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<User> _citizensWithStatus(
    AdminProvider provider,
    bool Function(ApplicationStatus) matches,
  ) {
    final ids = provider.applications
        .where((a) => a.cardTypeId == _selectedCardTypeId && matches(a.status))
        .map((a) => a.applicantId)
        .whereType<String>()
        .toSet();
    return provider.citizens.where((c) => ids.contains(c.id)).toList();
  }

  Widget _buildCitizenList(AdminProvider provider, List<CardType> cardTypes) {
    final cardType = cardTypes
        .where((c) => c.id == _selectedCardTypeId)
        .firstOrNull;

    final pending = _citizensWithStatus(
      provider,
      (s) =>
          s == ApplicationStatus.submitted ||
          s == ApplicationStatus.underReview,
    );
    final approved = _citizensWithStatus(
      provider,
      (s) => s == ApplicationStatus.approved,
    );
    final rejected = _citizensWithStatus(
      provider,
      (s) => s == ApplicationStatus.rejected,
    );
    final hasAny =
        pending.isNotEmpty || approved.isNotEmpty || rejected.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _selectedCardTypeId = null),
              ),
              Expanded(
                child: Text(
                  cardType?.name ?? '',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: context.tr('search_by_name_nid'),
              prefixIcon: const Icon(Icons.search),
            ),
            onSubmitted: (v) =>
                context.read<AdminProvider>().loadCitizens(search: v),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadCitizens(),
            child: provider.isLoadingCitizens
                ? const Center(child: CircularProgressIndicator())
                : provider.citizensError != null
                ? ErrorMessage(
                    message: provider.citizensError!,
                    onRetry: () => provider.loadCitizens(),
                  )
                : !hasAny
                ? EmptyListMessage(
                    message: context.tr('no_citizen_accounts'),
                    icon: Icons.people_outline,
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (pending.isNotEmpty) ...[
                        _SectionHeader(
                          title: context.trp('citizens_count_label', {
                            'count': '${pending.length}',
                          }),
                          label: context.tr('stat_pending_review'),
                          color: AppTheme.warningAmber,
                        ),
                        ...pending.map(_citizenTile),
                      ],
                      if (approved.isNotEmpty) ...[
                        _SectionHeader(
                          title: context.trp('citizens_count_label', {
                            'count': '${approved.length}',
                          }),
                          label: context.tr('stat_approved'),
                          color: AppTheme.successGreen,
                        ),
                        ...approved.map(_citizenTile),
                      ],
                      if (rejected.isNotEmpty) ...[
                        _SectionHeader(
                          title: context.trp('citizens_count_label', {
                            'count': '${rejected.length}',
                          }),
                          label: context.tr('stat_rejected'),
                          color: AppTheme.errorRed,
                        ),
                        ...rejected.map(_citizenTile),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _citizenTile(User citizen) {
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
        title: Text(
          citizen.fullName.isNotEmpty ? citizen.fullName : citizen.email,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
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
          itemBuilder: (menuContext) => !citizen.isActive
              ? [
                  PopupMenuItem(
                    value: 'activate',
                    child: Text(context.trs('activate_action')),
                  ),
                ]
              : [
                  if (citizen.isFrozen)
                    PopupMenuItem(
                      value: 'unfreeze',
                      child: Text(context.trs('unfreeze_action')),
                    )
                  else
                    PopupMenuItem(
                      value: 'freeze',
                      child: Text(context.trs('freeze_action')),
                    ),
                  PopupMenuItem(
                    value: 'deactivate',
                    child: Text(
                      context.trs('deactivate_action'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!citizen.isActive)
                _StatusBadge(
                  label: context.trs('status_inactive'),
                  color: Colors.red,
                )
              else if (citizen.isFrozen)
                _StatusBadge(
                  label: context.trs('status_frozen'),
                  color: Colors.blue,
                ),
              const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.title,
    required this.color,
  });

  final String label;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
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
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
