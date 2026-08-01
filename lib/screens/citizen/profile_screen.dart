import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingPhoto = false;

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }

  Future<void> _pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile({'profile_picture': path});
    if (!mounted) return;
    setState(() => _isUploadingPhoto = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.trs('photo_updated_success')
              : auth.errorMessage ?? context.trs('failed_update_photo'),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _editName(User? user) async {
    final firstController = TextEditingController(text: user?.firstName ?? '');
    final lastController = TextEditingController(text: user?.lastName ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('edit_name_title')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstController,
                decoration: InputDecoration(
                  labelText: dialogContext.tr('first_name_label'),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? dialogContext.trs('field_required')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lastController,
                decoration: InputDecoration(
                  labelText: dialogContext.tr('last_name_label'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(dialogContext.tr('save_action')),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final auth = context.read<AuthProvider>();
      final success = await auth.updateProfile({
        'first_name': firstController.text.trim(),
        'last_name': lastController.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? context.trs('name_updated_success')
                : auth.errorMessage ?? context.trs('failed_save_profile'),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('change_password_title')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: dialogContext.tr('current_password_label'),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? dialogContext.trs('field_required')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: dialogContext.tr('new_password_label'),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? dialogContext.trs('at_least_6_chars')
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(dialogContext.tr('save_action')),
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
          content: Text(
            success
                ? context.trs('password_changed_success')
                : auth.errorMessage ?? context.trs('failed_change_password'),
          ),
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
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 16,
              24,
              28,
            ),
            decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    tooltip: context.tr('logout'),
                    onPressed: _logout,
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      backgroundImage: avatarImageFor(user?.profilePictureUrl),
                      child: avatarImageFor(user?.profilePictureUrl) == null
                          ? const Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: -4,
                      child: GestureDetector(
                        onTap: _isUploadingPhoto ? null : _pickProfilePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: _isUploadingPhoto
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName
                          : context.tr('role_citizen'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _editName(user),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
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
                      _ProfileRow(
                        icon: Icons.badge_rounded,
                        color: AppTheme.primaryGreen,
                        label: context.tr('nid_short_label'),
                        value: user?.nid ?? '-',
                      ),
                      const Divider(height: 1, indent: 60),
                      _ProfileRow(
                        icon: Icons.email_rounded,
                        color: AppTheme.infoBlue,
                        label: context.tr('email_short_label'),
                        value: user?.email ?? '-',
                      ),
                      const Divider(height: 1, indent: 60),
                      _ProfileRow(
                        icon: Icons.phone_rounded,
                        color: AppTheme.successGreen,
                        label: context.tr('phone_field_label'),
                        value: user?.phone ?? '-',
                      ),
                      const Divider(height: 1, indent: 60),
                      _ProfileRow(
                        icon: Icons.location_on_rounded,
                        color: AppTheme.warningAmber,
                        label: context.tr('address_label'),
                        value: user?.address ?? '-',
                      ),
                      const Divider(height: 1, indent: 60),
                      _ProfileRow(
                        icon: Icons.work_rounded,
                        color: AppTheme.accentRed,
                        label: context.tr('occupation_label'),
                        value: user?.occupation ?? '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push('/citizen/profile-completion'),
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(context.tr('edit_profile_action')),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _changePassword,
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: Text(context.tr('change_password_title')),
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
  const _ProfileRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
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
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
