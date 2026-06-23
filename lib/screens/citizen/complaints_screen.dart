import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/complaint.dart';
import 'package:onecitizen/providers/complaint_provider.dart';
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

Color _complaintStatusColor(ComplaintStatus status) {
  switch (status) {
    case ComplaintStatus.resolved:
      return Colors.green;
    case ComplaintStatus.inProgress:
      return Colors.orange;
    case ComplaintStatus.open:
      return Colors.blue;
  }
}

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintProvider>().loadComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = context.watch<ComplaintProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('My Complaints'),
      ),
      body: RefreshIndicator(
        onRefresh: () => complaintProvider.loadComplaints(),
        child: complaintProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : complaintProvider.complaints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.report_problem_outlined,
                          size: 60,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No complaints filed yet.',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              context.push('/citizen/complaints/new'),
                          child: const Text('File a new complaint'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: complaintProvider.complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = complaintProvider.complaints[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(complaint.subject),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('dd MMM yyyy HH:mm')
                                  .format(complaint.createdAt)),
                              Text(
                                complaint.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: StatusBadge(
                            label: complaint.status.name,
                            color: _complaintStatusColor(complaint.status),
                          ),
                          onTap: () => context.push(
                              '/citizen/complaints/${complaint.id}',
                              extra: complaint),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/citizen/complaints/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
      ),
    );
  }
}

class ComplaintDetailScreen extends StatelessWidget {
  const ComplaintDetailScreen({super.key, required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('Complaint Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            complaint.subject,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: complaint.status.name,
                          color: _complaintStatusColor(complaint.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Filed on: ${DateFormat('dd MMM yyyy HH:mm').format(complaint.createdAt)}',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      complaint.description,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            if (complaint.status == ComplaintStatus.resolved &&
                complaint.resolution != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Resolution',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(complaint.resolution!),
                      if (complaint.resolvedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Resolved on: ${DateFormat('dd MMM yyyy').format(complaint.resolvedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ComplaintFormScreen extends StatefulWidget {
  const ComplaintFormScreen({super.key});

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final complaintProvider = context.read<ComplaintProvider>();

    try {
      final success = await complaintProvider.submitComplaint(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint filed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              complaintProvider.error ?? 'Failed to file complaint',
            ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('File a New Complaint'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g., Issue with Farmer Card application',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a subject'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your complaint in detail',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitComplaint,
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
                        'Submit Complaint',
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
