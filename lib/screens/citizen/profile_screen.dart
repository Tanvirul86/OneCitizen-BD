import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }

  Future<void> _changePassword() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final auth = context.read<AuthProvider>();
      final success = await auth.changePassword(
        oldPassword: oldController.text,
        newPassword: newController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Password changed successfully' : auth.errorMessage ?? 'Failed to change password'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 28),
            decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    tooltip: 'Logout',
                    onPressed: _logout,
                  ),
                ),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  backgroundImage: user?.profilePictureUrl != null ? NetworkImage(user!.profilePictureUrl!) : null,
                  child: user?.profilePictureUrl == null ? const Icon(Icons.person_rounded, size: 48, color: Colors.white) : null,
                ),
                const SizedBox(height: 14),
                Text(
                  user?.fullName.isNotEmpty == true ? user!.fullName : 'Citizen',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      _ProfileRow(icon: Icons.badge_rounded, color: AppTheme.primaryGreen, label: 'NID', value: user?.nid ?? '-'),
                      const Divider(height: 1, indent: 60),
                      _ProfileRow(icon: Icons.email_rounded, color: AppTheme.infoBlue, label: 'Email', value: user?.email ?? '-'),
                      const Divider(height: 1, indent: 60),
                      _ProfileRow(icon: Icons.phone_rounded, color: AppTheme.successGreen, label: 'Phone', value: user?.phone ?? '-'),
                      const Divider(height: 1, indent: 60),
                      _ProfileRow(icon: Icons.location_on_rounded, color: AppTheme.warningAmber, label: 'Address', value: user?.address ?? '-'),
                      const Divider(height: 1, indent: 60),
                      _ProfileRow(icon: Icons.work_rounded, color: AppTheme.accentRed, label: 'Occupation', value: user?.occupation ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push('/citizen/profile-completion'),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit Profile'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _changePassword,
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: const Text('Change Password'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.color, required this.label, required this.value});
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    );
  }
}
