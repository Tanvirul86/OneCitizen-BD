import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/complaint.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            label: 'Card Types',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Officers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Logs',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/admin/users')) return 1;
    if (location.startsWith('/admin/card-types')) return 2;
    if (location.startsWith('/admin/officers')) return 3;
    if (location.startsWith('/admin/complaints')) return 4;
    if (location.startsWith('/admin/logs')) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/users');
        break;
      case 2:
        context.go('/admin/card-types');
        break;
      case 3:
        context.go('/admin/officers');
        break;
      case 4:
        context.go('/admin/complaints');
        break;
      case 5:
        context.go('/admin/logs');
        break;
    }
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AdminProvider>();
      p.loadUsers();
      p.loadOfficers();
      p.loadCardTypes();
      p.loadComplaints();
      p.loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatTile(
                    context,
                    'Total Users',
                    '${adminProvider.users.length}',
                    Icons.people_alt,
                    () => context.go('/admin/users'),
                  ),
                  _buildStatTile(
                    context,
                    'Active Officers',
                    '${adminProvider.officers.length}',
                    Icons.work,
                    () => context.go('/admin/officers'),
                  ),
                  _buildStatTile(
                    context,
                    'Card Types',
                    '${adminProvider.cardTypes.length}',
                    Icons.credit_card,
                    () => context.go('/admin/card-types'),
                  ),
                  _buildStatTile(
                    context,
                    'Open Complaints',
                    '${adminProvider.complaints.where((c) => c.status == ComplaintStatus.open).length}',
                    Icons.report_problem,
                    () => context.go('/admin/complaints'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (adminProvider.logs.isEmpty)
                    const Text('No recent logs.')
                  else
                    ...adminProvider.logs.take(5).map(
                      (log) => ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(log['message'] as String),
                        subtitle: Text(log['timestamp'] as String),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String title, String value,
      IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: RefreshIndicator(
        onRefresh: () => adminProvider.loadUsers(),
        child: adminProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : adminProvider.users.isEmpty
                ? const Center(child: Text('No users found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: adminProvider.users.length,
                    itemBuilder: (context, index) {
                      final user = adminProvider.users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(user.fullName ?? 'N/A'),
                          subtitle: Text(user.phoneNumber),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (user.isActive)
                                IconButton(
                                  icon: const Icon(Icons.block, color: Colors.orange),
                                  onPressed: () {
                                    _showConfirmDialog(
                                      context,
                                      'Suspend User',
                                      'Are you sure you want to suspend ${user.fullName}?',
                                      () => adminProvider.suspendUser(user.id),
                                    );
                                  },
                                  tooltip: 'Suspend',
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () {
                                    _showConfirmDialog(
                                      context,
                                      'Reactivate User',
                                      'Are you sure you want to reactivate ${user.fullName}?',
                                      () => adminProvider.reactivateUser(user.id),
                                    );
                                  },
                                  tooltip: 'Reactivate',
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showConfirmDialog(
                                    context,
                                    'Delete User',
                                    'Are you sure you want to delete ${user.fullName}?',
                                    () => adminProvider.deleteUser(user.id),
                                  );
                                },
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class CardTypeManagementScreen extends StatefulWidget {
  const CardTypeManagementScreen({super.key});

  @override
  State<CardTypeManagementScreen> createState() =>
      _CardTypeManagementScreenState();
}

class _CardTypeManagementScreenState extends State<CardTypeManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCardTypes();
    });
  }

  Future<void> _showCardTypeForm({CardType? cardType}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => CardTypeForm(cardType: cardType),
    );
    if (result == true) {
      if (mounted) context.read<AdminProvider>().loadCardTypes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Card Type Management')),
      body: RefreshIndicator(
        onRefresh: () => adminProvider.loadCardTypes(),
        child: adminProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : adminProvider.cardTypes.isEmpty
                ? const Center(child: Text('No card types defined.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: adminProvider.cardTypes.length,
                    itemBuilder: (context, index) {
                      final cardType = adminProvider.cardTypes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.credit_card),
                          title: Text(cardType.name),
                          subtitle: Text(cardType.code),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showCardTypeForm(cardType: cardType),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete',
                                onPressed: () => _showConfirmDialog(
                                  context,
                                  'Delete Card Type',
                                  'Delete "${cardType.name}"? This cannot be undone.',
                                  () => context.read<AdminProvider>().deleteCardType(cardType.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCardTypeForm(),
        icon: const Icon(Icons.add),
        label: const Text('New Card Type'),
      ),
    );
  }
}

class CardTypeForm extends StatefulWidget {
  const CardTypeForm({super.key, this.cardType});

  final CardType? cardType;

  @override
  State<CardTypeForm> createState() => _CardTypeFormState();
}

// Human-readable labels for eligibility rule keys.
const _ruleLabels = <String, String>{
  'min_age': 'Minimum Age',
  'max_age': 'Maximum Age',
  'min_income': 'Minimum Monthly Income (BDT)',
  'max_income': 'Maximum Monthly Income (BDT)',
  'min_land_holding': 'Minimum Land Holding (Acres)',
  'max_land_holding': 'Maximum Land Holding (Acres)',
  'occupations': 'Allowed Occupations (comma-separated)',
};

class _CardTypeFormState extends State<CardTypeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _docControllers = [];
  final Map<String, TextEditingController> _ruleControllers = {};
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.cardType != null) {
      _nameController.text = widget.cardType!.name;
      _codeController.text = widget.cardType!.code;
      _descriptionController.text = widget.cardType!.description ?? '';
      _isActive = widget.cardType!.isActive;
      for (final doc in widget.cardType!.requiredDocuments) {
        _docControllers.add(TextEditingController(text: doc));
      }
      widget.cardType!.eligibilityRules.forEach((key, value) {
        _ruleControllers[key] =
            TextEditingController(text: value.toString());
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    for (final controller in _docControllers) {
      controller.dispose();
    }
    for (final controller in _ruleControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addEligibilityRule(String key) {
    setState(() {
      _ruleControllers[key] = TextEditingController();
    });
  }

  void _removeEligibilityRule(String key) {
    setState(() {
      _ruleControllers[key]?.dispose();
      _ruleControllers.remove(key);
    });
  }

  void _addDocumentField() {
    setState(() {
      _docControllers.add(TextEditingController());
    });
  }

  void _removeDocumentField(int index) {
    setState(() {
      _docControllers[index].dispose();
      _docControllers.removeAt(index);
    });
  }

  Future<void> _saveCardType() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final adminProvider = context.read<AdminProvider>();

    final newCardType = CardType(
      id: widget.cardType?.id ?? '',
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      description: _descriptionController.text.trim(),
      isActive: _isActive,
      requiredDocuments: _docControllers.map((e) => e.text.trim()).toList(),
      eligibilityRules: {
        for (final entry in _ruleControllers.entries)
          if (entry.value.text.trim().isNotEmpty)
            entry.key: entry.value.text.trim(),
      },
    );

    final success = await adminProvider.saveCardType(
      newCardType,
      id: widget.cardType?.id,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card type saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                adminProvider.error ?? 'Failed to save card type.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.cardType == null ? 'Create Card Type' : 'Edit Card Type',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Card Name'),
                validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Card Code'),
                validator: (v) => v?.isEmpty ?? true ? 'Code is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeThumbColor: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 16),
              const Text(
                'Required Documents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ..._docControllers.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                labelText: 'Document ${entry.key + 1} Name',
                              ),
                              validator: (v) => v?.isEmpty ?? true
                                  ? 'Document name is required'
                                  : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => _removeDocumentField(entry.key),
                          ),
                        ],
                      ),
                    ),
                  ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addDocumentField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Document Field'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Eligibility Rules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Define criteria a citizen must meet to be eligible for this card.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              ..._ruleControllers.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: entry.value,
                          keyboardType: entry.key == 'occupations'
                              ? TextInputType.text
                              : TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _ruleLabels[entry.key] ?? entry.key,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () => _removeEligibilityRule(entry.key),
                        tooltip: 'Remove rule',
                      ),
                    ],
                  ),
                ),
              ),
              if (_ruleControllers.length < _ruleLabels.length)
                Align(
                  alignment: Alignment.centerLeft,
                  child: PopupMenuButton<String>(
                    onSelected: _addEligibilityRule,
                    itemBuilder: (_) => _ruleLabels.entries
                        .where((e) => !_ruleControllers.containsKey(e.key))
                        .map(
                          (e) => PopupMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    child: TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Eligibility Rule'),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCardType,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Card Type',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OfficerManagementScreen extends StatefulWidget {
  const OfficerManagementScreen({super.key});

  @override
  State<OfficerManagementScreen> createState() =>
      _OfficerManagementScreenState();
}

class _OfficerManagementScreenState extends State<OfficerManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadOfficers();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createOfficer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final adminProvider = context.read<AdminProvider>();

    try {
      final success = await adminProvider.createOfficer(
        _phoneController.text.trim(),
        _nameController.text.trim(),
      );
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Officer account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _phoneController.clear();
        _nameController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProvider.error ?? 'Failed to create officer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Officer Management')),
      body: RefreshIndicator(
        onRefresh: () => adminProvider.loadOfficers(),
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create New Officer Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '01XXXXXXXXX',
                          prefixText: '+88 ',
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter phone number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Officer Full Name',
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter full name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _createOfficer,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Officer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: adminProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : adminProvider.officers.isEmpty
                      ? const Center(child: Text('No officers found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: adminProvider.officers.length,
                          itemBuilder: (context, index) {
                            final officer = adminProvider.officers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.work)),
                                title: Text(officer.fullName ?? 'N/A'),
                                subtitle: Text(officer.phoneNumber),
                                trailing: IconButton(
                                  icon: const Icon(Icons.person_remove, color: Colors.red),
                                  tooltip: 'Remove Officer',
                                  onPressed: () => _showConfirmDialog(
                                    context,
                                    'Remove Officer',
                                    'Remove ${officer.fullName ?? officer.phoneNumber} from officers?',
                                    () => context.read<AdminProvider>().removeOfficer(officer.id),
                                  ),
                                ),
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

class ComplaintOversightScreen extends StatefulWidget {
  const ComplaintOversightScreen({super.key});

  @override
  State<ComplaintOversightScreen> createState() =>
      _ComplaintOversightScreenState();
}

class _ComplaintOversightScreenState extends State<ComplaintOversightScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadComplaints();
    });
  }

  Future<void> _showResolveComplaintDialog(Complaint complaint) async {
    final resolutionController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Subject: ${complaint.subject}'),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolution',
                hintText: 'Enter resolution details',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (resolutionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resolution cannot be empty'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);
      final adminProvider = context.read<AdminProvider>();
      try {
        await adminProvider.resolveComplaint(
            complaint.id, resolutionController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint resolved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(adminProvider.error ?? 'Failed to resolve complaint'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
    resolutionController.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Oversight')),
      body: RefreshIndicator(
        onRefresh: () => adminProvider.loadComplaints(),
        child: adminProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : adminProvider.complaints.isEmpty
                ? const Center(child: Text('No complaints filed.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: adminProvider.complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = adminProvider.complaints[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.report_problem_outlined),
                          title: Text(complaint.subject),
                          subtitle: Text(
                              'By: ${complaint.citizenName ?? 'N/A'} - ${complaint.createdAt.toLocal().toString().split(' ')[0]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatusBadge(status: complaint.status.name),
                              if (complaint.status == ComplaintStatus.open)
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: _isLoading
                                      ? null
                                      : () =>
                                          _showResolveComplaintDialog(complaint),
                                  tooltip: 'Resolve Complaint',
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class SystemLogsScreen extends StatefulWidget {
  const SystemLogsScreen({super.key});

  @override
  State<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends State<SystemLogsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final filtered = _query.isEmpty
        ? adminProvider.logs
        : adminProvider.logs.where((log) {
            final msg = (log['message'] as String? ?? '').toLowerCase();
            final ts = (log['timestamp'] as String? ?? '').toLowerCase();
            return msg.contains(_query) || ts.contains(_query);
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('System Logs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search logs…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => adminProvider.loadLogs(),
              child: adminProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(child: Text('No logs found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final log = filtered[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: Text(log['message'] as String? ?? ''),
                                subtitle: Text(log['timestamp'] as String? ?? ''),
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

Future<void> _showConfirmDialog(BuildContext context, String title,
    String content, VoidCallback onConfirm) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => context.pop(true),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );

  if (result == true) {
    onConfirm();
  }
}
