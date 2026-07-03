import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/providers/notification_provider.dart';
import 'package:onecitizen/widgets/app_logo.dart';
import 'package:provider/provider.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadApplications();
      context.read<ApplicationProvider>().loadDocuments();
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  Color _statusColor(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.approved:
        return AppTheme.successGreen;
      case ApplicationStatus.rejected:
        return AppTheme.errorRed;
      case ApplicationStatus.underReview:
        return AppTheme.infoBlue;
      case ApplicationStatus.submitted:
        return AppTheme.warningAmber;
    }
  }

  String _statusLabel(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final appProvider = context.watch<ApplicationProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final invalidDocs = appProvider.documents.where((d) => d.isValid == false).length;
    final recentApps = appProvider.applications.take(3).toList();
    final greeting = _greeting();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () => Future.wait([
          context.read<ApplicationProvider>().loadApplications(),
          context.read<NotificationProvider>().loadNotifications(),
        ]),
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 180,
              backgroundColor: AppTheme.primaryGreenDark,
              foregroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                greeting,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.fullName.isNotEmpty == true
                                    ? user!.fullName
                                    : 'Citizen',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: Row(
                children: [
                  const AppLogo(size: 26, onDark: true),
                  const SizedBox(width: 8),
                  Text(
                    'OneCitizen BD',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 24),
                      onPressed: () => context.go('/citizen/notifications'),
                    ),
                    if (notifProvider.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentRed,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${notifProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Alert banners ──────────────────────────────────────
                  if (user != null && !user.profileComplete) ...[
                    _AlertCard(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Complete Your Profile',
                      subtitle: 'Profile completion is required to check eligibility for welfare cards.',
                      color: AppTheme.warningAmber,
                      actionLabel: 'Complete Now',
                      onAction: () => context.push('/citizen/profile-completion'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (invalidDocs > 0) ...[
                    _AlertCard(
                      icon: Icons.warning_amber_rounded,
                      title: '$invalidDocs Document${invalidDocs > 1 ? 's' : ''} Need Re-upload',
                      subtitle: 'Some of your documents were marked invalid by the admin.',
                      color: AppTheme.errorRed,
                      actionLabel: 'Fix Now',
                      onAction: () => context.push('/citizen/documents'),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Quick Actions ──────────────────────────────────────
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      _ActionCard(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Check Eligibility',
                        subtitle: 'Submit for admin review',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => context.push('/citizen/eligibility'),
                      ),
                      _ActionCard(
                        icon: Icons.add_card_rounded,
                        title: 'Apply for Card',
                        subtitle: 'New application',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFBE185D), Color(0xFFEC4899)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => context.push('/citizen/apply'),
                      ),
                      _ActionCard(
                        icon: Icons.upload_file_rounded,
                        title: 'Upload Docs',
                        subtitle: 'Manage documents',
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryGreenDark, AppTheme.primaryGreenLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        badge: invalidDocs > 0 ? invalidDocs : null,
                        onTap: () => context.push('/citizen/documents'),
                      ),
                      _ActionCard(
                        icon: Icons.payments_rounded,
                        title: 'Fund History',
                        subtitle: 'Distribution records',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B21B6), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => context.go('/citizen/distributions'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Applications ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Applications',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/citizen/applications'),
                        child: Text(
                          'View All',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (appProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (appProvider.applications.isEmpty)
                    _EmptyBox(
                      icon: Icons.assignment_outlined,
                      title: 'No applications yet',
                      subtitle: 'Check your eligibility first, then apply for a welfare card.',
                      actionLabel: 'Check Eligibility',
                      onAction: () => context.push('/citizen/eligibility'),
                    )
                  else
                    ...recentApps.map((app) => _AppCard(
                          app: app,
                          statusColor: _statusColor(app.status),
                          statusLabel: _statusLabel(app.status),
                          onTap: () => context.push('/citizen/applications/${app.id}'),
                        )),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.actionLabel,
    required this.onAction,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionLabel,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.badge,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                if (badge != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({
    required this.app,
    required this.statusColor,
    required this.statusLabel,
    required this.onTap,
  });
  final Application app;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.assignment_rounded, color: statusColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.cardTypeName,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('dd MMM yyyy').format(app.submittedAt),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: GoogleFonts.plusJakartaSans(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: AppTheme.primaryGreen.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
